import fs from 'node:fs/promises';
import path from 'node:path';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);
const root = path.resolve('.pptx_build');
const tree = path.join(root, 'tree');
const outDir = path.resolve('artifacts');
const out = path.join(outDir, 'CircleTrackerApp_紹介資料.pptx');
const EMU = 914400;
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
const emu = (n) => Math.round(n * EMU);
const color = { navy: '081526', panel: '10243A', cyan: '6EE7F9', blue: '2CA6F7', white: 'F5FAFF', muted: 'AFC1D4', line: '29445D', orange: 'FFB86B', green: '86E6B1' };

const files = new Map();
function put(p, s) { files.set(p, s); }
function shape({x, y, w, h, fill = null, line = null, radius = false, text = null, fontSize = 20, bold = false, font = 'Aptos', textColor = color.white, align = 'left', valign = 'mid', margin = 0.08, italic = false}) {
  const geom = radius ? '<a:prstGeom prst="roundRect"><a:avLst/></a:prstGeom>' : '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>';
  const fillXml = fill ? `<a:solidFill><a:srgbClr val="${fill}"/></a:solidFill>` : '<a:noFill/>';
  const lineXml = line ? `<a:ln w="12700"><a:solidFill><a:srgbClr val="${line}"/></a:solidFill></a:ln>` : '<a:ln><a:noFill/></a:ln>';
  const tx = text === null ? '' : `<p:txBody><a:bodyPr wrap="square" anchor="${valign === 'top' ? 't' : valign === 'bottom' ? 'b' : 'ctr'}" lIns="${emu(margin)}" rIns="${emu(margin)}" tIns="${emu(margin)}" bIns="${emu(margin)}"/><a:lstStyle/><a:p><a:pPr algn="${align}"/><a:r><a:rPr lang="ja-JP" sz="${fontSize * 100}" b="${bold ? 1 : 0}" i="${italic ? 1 : 0}"><a:solidFill><a:srgbClr val="${textColor}"/></a:solidFill><a:latin typeface="${font}"/><a:ea typeface="${font}"/></a:rPr><a:t>${esc(text)}</a:t></a:r><a:endParaRPr lang="ja-JP" sz="${fontSize * 100}"/></a:p></p:txBody>`;
  return `<p:sp><p:nvSpPr><p:cNvPr id="${shape.id = ++shape.nextId}" name="Shape ${shape.id}"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="${emu(x)}" y="${emu(y)}"/><a:ext cx="${emu(w)}" cy="${emu(h)}"/></a:xfrm>${geom}${fillXml}${lineXml}</p:spPr>${tx}</p:sp>`;
}
shape.nextId = 1;
function line(x1, y1, x2, y2, stroke = color.cyan, width = 2) {
  return `<p:cxnSp><p:nvCxnSpPr><p:cNvPr id="${++shape.nextId}" name="Line ${shape.nextId}"/><p:cNvCxnSpPr/><p:nvPr/></p:nvCxnSpPr><p:spPr><a:xfrm><a:off x="${emu(x1)}" y="${emu(y1)}"/><a:ext cx="${emu(x2-x1)}" cy="${emu(y2-y1)}"/></a:xfrm><a:prstGeom prst="line"><a:avLst/></a:prstGeom><a:ln w="${width*12700}"><a:solidFill><a:srgbClr val="${stroke}"/></a:solidFill><a:tailEnd type="triangle"/></a:ln></p:spPr></p:cxnSp>`;
}
function text(x, y, w, h, t, fs=20, opts={}) { return shape({x,y,w,h,text:t,fontSize:fs,...opts}); }
function slideXml(body, bg=color.navy) {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"><p:cSld><p:bg><p:bgPr><a:solidFill><a:srgbClr val="${bg}"/></a:solidFill><a:effectLst/></p:bgPr></p:bg><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr/>${body}</p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>`;
}
function slideRels() { return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/></Relationships>`; }
function titleBlock(kicker, title, subtitle='') { return text(0.7,0.42,11.8,0.28,kicker.toUpperCase(),11,{bold:true,textColor:color.cyan,margin:0}) + text(0.7,0.78,11.9,0.62,title,28,{bold:true,margin:0}) + (subtitle ? text(0.72,1.42,11.5,0.38,subtitle,14,{textColor:color.muted,margin:0}) : ''); }
function footer(n) { return text(0.72,7.18,11.8,0.18,`CIRCLETRACKERAPP  /  ${String(n).padStart(2,'0')}`,9,{textColor:color.muted,margin:0}); }

// 1. Cover
let b = '';
b += text(0.78,0.7,4,0.3,'CIRCLETRACKERAPP',14,{bold:true,textColor:color.cyan,margin:0});
b += text(0.78,1.45,7.3,1.5,'描いた円が、\nその場所に浮かんで見える',34,{bold:true,margin:0,valign:'top'});
b += text(0.82,3.45,5.5,0.65,'iPhoneを動かして円を描くと、\nその軌跡をカメラ越しに見返せる',17,{textColor:color.muted,margin:0,valign:'top'});
b += shape({x:8.0,y:0.9,w:4.3,h:5.8,fill:color.panel,line:color.line,radius:true});
b += shape({x:8.35,y:1.25,w:3.6,h:5.1,fill:'07111F',line:color.cyan,radius:true});
for (const [x,y] of [[9.0,2.1],[9.65,1.75],[10.4,1.9],[10.95,2.45],[11.2,3.2],[10.95,4.0],[10.35,4.55],[9.55,4.7],[8.95,4.3],[8.72,3.55],[8.8,2.75]]) b += shape({x,y,w:0.12,h:0.12,fill:color.cyan,line:null,radius:true});
b += line(8.95,2.18,9.65,1.83,color.cyan,2)+line(9.65,1.83,10.4,1.98,color.cyan,2)+line(10.4,1.98,10.95,2.53,color.cyan,2)+line(10.95,2.53,11.2,3.28,color.cyan,2)+line(11.2,3.28,10.95,4.08,color.cyan,2)+line(10.95,4.08,10.35,4.63,color.cyan,2)+line(10.35,4.63,9.55,4.78,color.cyan,2)+line(9.55,4.78,8.95,4.38,color.cyan,2)+line(8.95,4.38,8.72,3.63,color.cyan,2)+line(8.72,3.63,8.8,2.83,color.cyan,2)+line(8.8,2.83,8.95,2.18,color.cyan,2);
b += text(8.65,5.7,3,0.3,'TRACK  →  ANALYZE  →  SEE',11,{bold:true,textColor:color.cyan,align:'center',margin:0});
b += text(0.82,6.65,5,0.25,'プロジェクト紹介資料  |  2026',10,{textColor:color.muted,margin:0});
put('ppt/slides/slide1.xml', slideXml(b));

// 2. Concept
b = titleBlock('01  What it does','このアプリでできること','iPhoneで描いた円を、あとから同じ空間で確認する');
const steps = [
  ['01','じっとする','3秒間静止して\nスタート位置を決める',color.blue],
  ['02','円を描く','iPhoneを動かして\n空中に円を描く',color.cyan],
  ['03','カメラで見る','描いた場所に\n軌跡が浮かんで見える',color.green],
];
steps.forEach((s,i)=>{ const x=0.8+i*4.15; b+=shape({x,y:2.35,w:3.45,h:2.6,fill:color.panel,line:color.line,radius:true}); b+=text(x+0.25,2.65,0.5,0.3,s[0],14,{bold:true,textColor:s[3],margin:0}); b+=text(x+0.25,3.08,2.8,0.35,s[1],19,{bold:true,margin:0}); b+=text(x+0.25,3.65,2.9,0.7,s[2],16,{textColor:color.muted,margin:0,valign:'top'}); if(i<2)b+=line(x+3.55,3.65,x+4.05,3.65,color.cyan,2); });
b += text(0.82,5.55,11.0,0.55,'「どこに、どんな円を描いたか」が目で分かる',24,{bold:true,textColor:color.cyan,margin:0});
b += text(0.82,6.12,10.8,0.45,'円の形だけでなく、手の動きの軌跡も残る',15,{textColor:color.muted,margin:0});
b += footer(2); put('ppt/slides/slide2.xml', slideXml(b));

// 3. Flow
b = titleBlock('02  How to use','使い方は3ステップ','記録が終わると、AR PREVIEWで描いた場所を見返せる');
const flow = [
  ['HOME','START','アプリを開く'],['TRACKING','3秒静止','スタート位置を決める'],['TRACKING','円を描く','iPhoneを動かす'],['TRACKING','AR PREVIEW','描いた場所を見る'],['RESULT','結果を見る','採点・もう一度']
];
flow.forEach((f,i)=>{const x=0.65+i*2.5; b+=shape({x,y:2.55,w:2.12,h:1.58,fill:i===3?'173C4D':color.panel,line:i===3?color.cyan:color.line,radius:true}); b+=text(x+0.17,2.8,1.75,0.28,f[0],11,{bold:true,textColor:i===3?color.cyan:color.muted,margin:0}); b+=text(x+0.17,3.15,1.75,0.28,f[1],15,{bold:true,margin:0}); b+=text(x+0.17,3.52,1.75,0.25,f[2],11,{textColor:color.muted,margin:0}); if(i<flow.length-1)b+=line(x+2.17,3.35,x+2.42,3.35,color.cyan,2);});
b += text(0.8,4.85,2.1,0.3,'覚えておくこと',15,{bold:true,textColor:color.cyan,margin:0});
b += text(0.82,5.35,5.2,0.75,'• 最初に3秒間、iPhoneを動かさない\n• 円を描き終えたらAR PREVIEWを押す\n• RETRYで最初からやり直せる',15,{textColor:color.white,margin:0,valign:'top'});
b += shape({x:7.3,y:4.82,w:5.0,h:1.55,fill:'0D2B3A',line:color.cyan,radius:true});
b += text(7.65,5.12,4.4,0.3,'AR PREVIEW',20,{bold:true,textColor:color.cyan,align:'center',margin:0});
b += text(7.65,5.55,4.4,0.5,'描いた場所を確認してから\n結果画面へ進める',14,{textColor:color.muted,align:'center',margin:0,valign:'top'});
b += footer(3); put('ppt/slides/slide3.xml', slideXml(b));

// 4. Mechanics
b = titleBlock('03  AR preview','AR PREVIEWで見えるもの','カメラを向けると、描いた軌跡が小さな点になって現れる');
b += shape({x:0.75,y:2.1,w:5.2,h:4.2,fill:'07111F',line:color.line,radius:true});
b += text(1.05,2.4,4.5,0.3,'カメラに映る空間',14,{bold:true,textColor:color.muted,margin:0});
b += line(1.35,5.55,4.9,5.55,color.orange,2)+line(1.35,5.55,1.35,2.95,color.green,2)+line(1.35,5.55,2.7,4.2,color.blue,2);
b += text(4.92,5.42,0.5,0.25,'X',11,{textColor:color.orange,margin:0}); b+=text(1.2,2.72,0.5,0.25,'Y',11,{textColor:color.green,margin:0}); b+=text(2.76,3.96,0.5,0.25,'Z',11,{textColor:color.blue,margin:0});
b += shape({x:2.55,y:4.35,w:0.16,h:0.16,fill:color.orange,line:null,radius:true}); b+=text(2.75,4.23,1.7,0.25,'origin',12,{bold:true,textColor:color.orange,margin:0});
for (const [x,y] of [[2.1,3.85],[2.7,3.45],[3.4,3.55],[4.0,3.95],[4.25,4.65],[4.0,5.15],[3.35,5.35],[2.65,5.2],[2.15,4.7]]) b += shape({x,y,w:0.11,h:0.11,fill:color.cyan,line:null,radius:true});
b += text(6.45,2.2,5.3,0.3,'描いた場所を基準にする',17,{bold:true,textColor:color.cyan,margin:0});
b += text(6.45,2.8,5.3,0.65,'1  最初に決めたスタート位置を基準にする\n2  記録した点を、その位置から並べる',17,{margin:0,valign:'top'});
b += line(6.45,4.0,11.7,4.0,color.line,1);
b += text(6.45,4.35,5.0,0.35,'描いた円が、ずれずに浮かぶ',20,{bold:true,margin:0});
b += text(6.45,4.95,5.25,0.7,'カメラ映像を背景に、\n記録した軌跡を同じ空間へ戻して表示',15,{textColor:color.muted,margin:0,valign:'top'});
b += footer(4); put('ppt/slides/slide4.xml', slideXml(b));

// 5. Architecture
b = titleBlock('04  Behind the scenes','アプリの中で起きていること','3つの役割で、動きの記録からAR表示までをつなぐ');
const nodes = [
  [0.9,2.25,2.45,1.15,'動きを測る','ARKitでiPhoneの位置を追う'],
  [4.25,2.25,3.1,1.15,'軌跡を記録','動いた点を順番に保存'],
  [8.25,2.25,3.15,1.15,'点をAR表示','RealityKitで球を置く'],
  [2.1,4.55,2.7,1.15,'形を採点','円らしさを分析'],
  [6.05,4.55,3.2,1.15,'カメラ映像','実際の空間を背景にする'],
];
nodes.forEach((n,i)=>{b+=shape({x:n[0],y:n[1],w:n[2],h:n[3],fill:i===4?'173C4D':color.panel,line:i===4?color.cyan:color.line,radius:true}); b+=text(n[0]+0.18,n[1]+0.22,n[2]-0.36,0.28,n[4],15,{bold:true,textColor:i===4?color.cyan:color.white,margin:0}); b+=text(n[0]+0.18,n[1]+0.62,n[2]-0.36,0.25,n[5],11,{textColor:color.muted,margin:0});});
b+=line(3.38,2.82,4.17,2.82,color.cyan,2)+line(7.4,2.82,8.17,2.82,color.cyan,2)+line(5.78,3.42,3.45,4.45,color.line,1)+line(6.8,3.42,7.4,4.45,color.cyan,2);
b += text(0.9,6.25,11.3,0.3,'既存の記録・採点機能を活かして、AR表示を追加',15,{bold:true,textColor:color.cyan,margin:0});
b += text(0.9,6.62,11.3,0.25,'記録した軌跡を、結果画面だけでなく実空間でも確認できる',12,{textColor:color.muted,margin:0});
b += footer(5); put('ppt/slides/slide5.xml', slideXml(b));

// 6. Current scope
b = titleBlock('05  Takeaway','このアプリが目指す体験','描いた動きを、数字だけでなく空間で見返す');
b += text(0.85,2.25,5.6,0.35,'できること',18,{bold:true,textColor:color.cyan,margin:0});
b += text(0.88,2.85,5.6,1.45,'• iPhoneの移動をARKitで3D記録\n• origin基準の相対座標で軌跡を保持\n• カメラ映像上に球の点群として再表示\n• AR PREVIEWからResultへ進み、RETRYも可能',16,{margin:0,valign:'top'});
b += text(7.0,2.25,5.0,0.35,'次の拡張候補',18,{bold:true,textColor:color.cyan,margin:0});
b += text(7.03,2.85,5.0,1.45,'• 点群を連続線やチューブへ発展\n• 軌跡の色・太さ・再生速度を調整\n• 実空間の円との誤差を可視化\n• 記録データの保存と比較',16,{margin:0,valign:'top'});
b += shape({x:0.85,y:5.35,w:11.4,h:0.78,fill:'0D2B3A',line:color.cyan,radius:true});
b += text(1.15,5.55,10.8,0.3,'記録した動きを、画面の中の数値ではなく、空間の中で確認できる',19,{bold:true,textColor:color.cyan,align:'center',margin:0});
b += footer(6); put('ppt/slides/slide6.xml', slideXml(b));

// 7. Git development history
b = titleBlock('06  Git history','開発の歩み','機能ごとに枝分かれしながら、記録・採点・AR表示まで積み上げた');
b += text(0.82,2.05,5.1,0.3,'主要なブランチ',16,{bold:true,textColor:color.cyan,margin:0});
const history = [
  ['09/13','feature/get_motion','ARKitで位置を取得\n原点補正を追加',color.blue],
  ['09/14','feature/trajectory','3D軌跡をResultへ\n点群で表示',color.cyan],
  ['09/16','feature/tracking_usability','自動記録・停止\nHaptic / CIも追加',color.green],
  ['09/17','feature/analysis_score','最小二乗法で採点\n手書きモードも追加',color.orange],
  ['09/23','feature/design','画面デザインを改善\n進捗バーを復活',color.blue],
];
history.forEach((h,i)=>{ const y=2.55+i*0.72; b+=shape({x:0.9,y:y+0.05,w:0.76,h:0.42,fill:h[3],line:null,radius:true}); b+=text(0.9,y+0.15,0.76,0.15,h[0],10,{bold:true,textColor:color.navy,align:'center',margin:0}); b+=text(1.95,y,3.0,0.22,h[1],13,{bold:true,margin:0}); b+=text(5.0,y,2.25,0.42,h[2],11,{textColor:color.muted,margin:0,valign:'top'}); if(i<history.length-1)b+=line(1.28,y+0.48,1.28,y+0.68,color.line,1); });
b += shape({x:7.75,y:2.15,w:4.45,h:3.85,fill:'173C4D',line:color.cyan,radius:true});
b += text(8.1,2.55,3.75,0.28,'そして現在',16,{bold:true,textColor:color.cyan,align:'center',margin:0});
b += text(8.15,3.15,3.65,0.72,'AR PREVIEW',26,{bold:true,align:'center',margin:0});
b += text(8.15,4.0,3.65,0.85,'記録した軌跡を\nカメラ映像上に表示',20,{bold:true,align:'center',margin:0,valign:'top'});
b += text(8.15,5.18,3.65,0.42,'originを基準に点群を復元',13,{textColor:color.muted,align:'center',margin:0});
b += text(0.9,6.45,11.2,0.35,'枝分かれした機能を、ひとつの体験に統合',20,{bold:true,textColor:color.cyan,margin:0});
b += text(0.9,6.82,11.2,0.22,'Gitの履歴：get_motion → trajectory → tracking_usability → analysis_score / drawing → design',11,{textColor:color.muted,margin:0});
b += footer(7); put('ppt/slides/slide7.xml', slideXml(b));

// Package boilerplate
put('[Content_Types].xml', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/><Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/><Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/><Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>${[1,2,3,4,5,6,7].map(i=>`<Override PartName="/ppt/slides/slide${i}.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>`).join('')}</Types>`);
put('_rels/.rels', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/></Relationships>`);
put('ppt/presentation.xml', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"><p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst><p:sldIdLst>${[1,2,3,4,5,6,7].map((i)=>`<p:sldId id="${255+i}" r:id="rId${i+1}"/>`).join('')}</p:sldIdLst><p:sldSz cx="12192000" cy="6858000" type="screen16x9"/><p:notesSz cx="6858000" cy="9144000"/><p:defaultTextStyle><a:defPPr/></p:defaultTextStyle></p:presentation>`);
put('ppt/_rels/presentation.xml.rels', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>${[1,2,3,4,5,6,7].map(i=>`<Relationship Id="rId${i+1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide${i}.xml"/>`).join('')}</Relationships>`);
put('ppt/slideMasters/slideMaster1.xml', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"><p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr/></p:spTree></p:cSld><p:clrMap accent1="FFFFFF" accent2="FFFFFF" accent3="FFFFFF" accent4="FFFFFF" accent5="FFFFFF" accent6="FFFFFF" bg1="FFFFFF" bg2="FFFFFF" folHlink="FFFFFF" hlink="FFFFFF" tx1="FFFFFF" tx2="FFFFFF"/><p:sldLayoutIdLst><p:sldLayoutId id="1" r:id="rId1"/></p:sldLayoutIdLst></p:sldMaster>`);
put('ppt/slideMasters/_rels/slideMaster1.xml.rels', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/></Relationships>`);
put('ppt/slideLayouts/slideLayout1.xml', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" type="blank"><p:cSld name="Blank"><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr/></p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>`);
put('ppt/slideLayouts/_rels/slideLayout1.xml.rels', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/></Relationships>`);
put('ppt/theme/theme1.xml', `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="CircleTracker"><a:themeElements><a:clrScheme name="CircleTracker"><a:dk1><a:srgbClr val="${color.navy}"/></a:dk1><a:lt1><a:srgbClr val="${color.white}"/></a:lt1><a:dk2><a:srgbClr val="${color.panel}"/></a:dk2><a:lt2><a:srgbClr val="FFFFFF"/></a:lt2><a:accent1><a:srgbClr val="${color.cyan}"/></a:accent1><a:accent2><a:srgbClr val="${color.blue}"/></a:accent2><a:accent3><a:srgbClr val="${color.green}"/></a:accent3><a:accent4><a:srgbClr val="${color.orange}"/></a:accent4><a:accent5><a:srgbClr val="${color.muted}"/></a:accent5><a:accent6><a:srgbClr val="${color.line}"/></a:accent6><a:hlink><a:srgbClr val="${color.cyan}"/></a:hlink><a:folHlink><a:srgbClr val="${color.cyan}"/></a:folHlink></a:clrScheme><a:fontScheme name="CircleTracker"><a:majorFont><a:latin typeface="Aptos Display"/><a:ea typeface="Aptos"/><a:cs typeface="Aptos"/></a:majorFont><a:minorFont><a:latin typeface="Aptos"/><a:ea typeface="Aptos"/><a:cs typeface="Aptos"/></a:minorFont></a:fontScheme><a:fmtScheme name="CircleTracker"><a:fillStyleLst/><a:lnStyleLst/><a:effectStyleLst/><a:bgFillStyleLst/></a:fmtScheme></a:themeElements></a:theme>`);
for (let i=1;i<=7;i++) put(`ppt/slides/_rels/slide${i}.xml.rels`, slideRels());

await fs.rm(tree, {recursive:true, force:true}); await fs.mkdir(outDir,{recursive:true});
for (const [p,s] of files) { const fp=path.join(tree,p); await fs.mkdir(path.dirname(fp),{recursive:true}); await fs.writeFile(fp,s); }
await fs.rm(out,{force:true});
await execFileAsync('zip',['-q','-r',out,'.'],{cwd:tree});
console.log(out);
