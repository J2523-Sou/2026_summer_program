import Foundation
import simd

struct CircleAnalyzer {
    
    static func analyze(
        points: [SIMD3<Float>]
    ) -> CircleAnalysisResult {
        
        // 解析失敗時の結果
        func failedResult() -> CircleAnalysisResult {
            CircleAnalysisResult(
                score: 0,
                aspectScore: 0,
                radialError: 0,
                pointCount: points.count
            )
        }
        
        // 点が少なすぎる場合は解析しない
        guard points.count >= 10 else {
            return failedResult()
        }
        
        
        // 各軸の値
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        let zs = points.map { $0.z }
        
        // 各軸の変化量
        let rangeX = xs.max()! - xs.min()!
        let rangeY = ys.max()! - ys.min()!
        let rangeZ = zs.max()! - zs.min()!
        
        
        // 一番変化の大きい2軸を選ぶ
        let ranges = [
            (axis: 0, range: rangeX),
            (axis: 1, range: rangeY),
            (axis: 2, range: rangeZ)
        ]
            .sorted {
                $0.range > $1.range
            }
        
        let axis1 = ranges[0].axis
        let axis2 = ranges[1].axis
        
        
        // 指定した軸の値を取得
        func value(
            _ point: SIMD3<Float>,
            axis: Int
        ) -> Float {
            
            switch axis {
            case 0:
                return point.x
                
            case 1:
                return point.y
                
            default:
                return point.z
            }
        }
        
        
        // 3D点群から2軸を取り出して2D化
        let u = points.map {
            value($0, axis: axis1)
        }
        
        let v = points.map {
            value($0, axis: axis2)
        }
        
        
        // Bounding Box
        let minU = u.min()!
        let maxU = u.max()!
        
        let minV = v.min()!
        let maxV = v.max()!
        
        let width = maxU - minU
        let height = maxV - minV
        
        guard width > 0,
              height > 0 else {
            return failedResult()
        }
        
        
        // 最小二乗法で円を推定
        guard let circle = fitCircle(
            x: u,
            y: v
        ) else {
            return failedResult()
        }
        
        let centerU = circle.centerX
        let centerV = circle.centerY
        let radius = circle.radius
        
        
        // 各点の中心からの距離
        var radii: [Float] = []
        
        for i in points.indices {
            
            let du = u[i] - centerU
            let dv = v[i] - centerV
            
            let pointRadius = sqrt(
                du * du + dv * dv
            )
            
            radii.append(pointRadius)
        }
        
        
        // 推定した円の半径からの平均絶対誤差
        let meanError =
        radii
            .map {
                abs($0 - radius)
            }
            .reduce(0, +)
        / Float(radii.count)
        
        // 円の大きさに依存しないよう正規化
        let radialError =
        meanError / radius
        
        
        // 縦横比
        let aspectScore =
        min(width, height)
        / max(width, height)
        
        
        // 半径誤差を0〜1のスコアへ変換
        let radialScore =
        max(
            0,
            1 - radialError * 3
        )
        
        
        // 50 : 50で仮採点
        let score =
        100 * (
            0.5 * aspectScore
            + 0.5 * radialScore
        )
        
        
        print("center:", centerU, centerV)
        print("radius:", radius)
        print("width:", width)
        print("height:", height)
        print("aspect:", aspectScore)
        print("radialError:", radialError)
        print("score:", score)
        
        
        return CircleAnalysisResult(
            score: Int(
                max(
                    0,
                    min(100, score)
                )
            ),
            aspectScore: aspectScore,
            radialError: radialError,
            pointCount: points.count
        )
    }
    
    
    // 2D点群に最も合う円を最小二乗法で求める
    private static func fitCircle(
        x: [Float],
        y: [Float]
    ) -> (
        centerX: Float,
        centerY: Float,
        radius: Float
    )? {
        
        let n = Float(x.count)
        
        var sumX: Float = 0
        var sumY: Float = 0
        
        var sumX2: Float = 0
        var sumY2: Float = 0
        var sumXY: Float = 0
        
        var sumXQ: Float = 0
        var sumYQ: Float = 0
        var sumQ: Float = 0
        
        
        for i in x.indices {
            
            let px = x[i]
            let py = y[i]
            
            // 円の式を線形化するために使用
            // q = x² + y²
            let q =
            px * px
            + py * py
            
            sumX += px
            sumY += py
            
            sumX2 += px * px
            sumY2 += py * py
            sumXY += px * py
            
            sumXQ += px * q
            sumYQ += py * q
            sumQ += q
        }
        
        
        // x² + y² = A x + B y + C
        // のA, B, Cを最小二乗法で求める
        let matrix = simd_float3x3(
            SIMD3(sumX2, sumXY, sumX),
            SIMD3(sumXY, sumY2, sumY),
            SIMD3(sumX,   sumY,   n)
        )
        
        let right = SIMD3<Float>(
            sumXQ,
            sumYQ,
            sumQ
        )
        
        
        // 逆行列を作れない場合は解析失敗
        let determinant =
        simd_determinant(matrix)
        
        guard abs(determinant) > 0.000001 else {
            return nil
        }
        
        
        // 連立方程式を解く
        let result =
        simd_inverse(matrix) * right
        
        let A = result.x
        let B = result.y
        let C = result.z
        
        
        // 円の中心
        let centerX = A / 2
        let centerY = B / 2
        
        
        // 円の半径
        let radiusSquared =
        C
        + centerX * centerX
        + centerY * centerY
        
        guard radiusSquared > 0 else {
            return nil
        }
        
        let radius =
        sqrt(radiusSquared)
        
        
        return (
            centerX,
            centerY,
            radius
        )
    }
}
