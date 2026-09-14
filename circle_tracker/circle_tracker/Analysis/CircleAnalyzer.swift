import Foundation
import simd

struct CircleAnalyzer {
    
    static func analyze(
        points: [SIMD3<Float>]
    ) -> CircleAnalysisResult {
        
        func failedResult() -> CircleAnalysisResult {
            CircleAnalysisResult(
                score: 0,
                aspectScore: 0,
                radialError: 0,
                pointCount: points.count
            )
        }
        
        guard points.count >= 10 else {
            return failedResult()
        }
        
        // 各軸の範囲
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        let zs = points.map { $0.z }
        
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
        
        let u = points.map {
            value($0, axis: axis1)
        }
        
        let v = points.map {
            value($0, axis: axis2)
        }
        
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
        
        // Bounding Boxの中心
        let centerU = (minU + maxU) / 2
        let centerV = (minV + maxV) / 2
        
        // 各点の半径
        var radii: [Float] = []
        
        for i in points.indices {
            
            let du = u[i] - centerU
            let dv = v[i] - centerV
            
            let radius = sqrt(
                du * du + dv * dv
            )
            
            radii.append(radius)
        }
        
        let meanRadius =
        radii.reduce(0, +)
        / Float(radii.count)
        
        guard meanRadius > 0 else {
            return failedResult()
        }
        
        // 半径の平均絶対誤差
        let meanError =
        radii
            .map {
                abs($0 - meanRadius)
            }
            .reduce(0, +)
        / Float(radii.count)
        
        let radialError =
        meanError / meanRadius
        
        // 縦横比
        let aspectScore =
        min(width, height)
        / max(width, height)
        
        // 半径誤差
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
        
        print("width:", width)
        print("height:", height)
        print("aspect:", aspectScore)
        print("radialError:", radialError)
        print("score:", score)
        
        return CircleAnalysisResult(
            score: Int(max(0, min(100, score))),
            aspectScore: aspectScore,
            radialError: radialError,
            pointCount: points.count
        )
    }
}
