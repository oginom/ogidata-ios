//
//  PlotDataViewBase.swift
//  OgiData3
//
//  Created by ma on 2018/02/23.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography
import SwiftyJSON

class PlotDataViewBase : DataViewBase {
    
    private var plotdata : [(Double, Double)] = []
    
    private var xlim : [Double] = [0,1]
    private var ylim : [Double] = [0,1]
    
    private var xGridInterval : Double = 1.0
    private var yGridInterval : Double = 1.0
    
    private var xTicks : [(val: Double, vals: String)] = []
    private var yTicks : [(val: Double, vals: String)] = []
    
    private var isPlotGrid = true
    
    private let plotview : UIView = {
        let ret = UIView()
        ret.isOpaque = true
        ret.backgroundColor = UIColor.clear
        return ret
    }()
    
    required init?(coder: NSCoder? = nil) {
        super.init(coder: coder)
        self.addSubview(plotview)
        self.isOpaque = true
        self.backgroundColor = UIColor.clear
    }
    
    override func setupConstraints() {
        print("plotDataViewBase.setupConstraints")
        constrain(plotview) {
            plotview in
            plotview.edges == inset(plotview.superview!.edges, 50, 30, 150, 10) // top, leading, bottom, trailing
        }
        super.setupConstraints()
    }
    
    override func setData(data : SwiftyJSON.JSON) {
        super.setData(data: data)
        self.preparePlot()
        self.setNeedsDisplay()
    }
    
    func preparePlot() {
        print("plotDataViewBase.preparePlot")
        plotdata = []
        if let data = self.data, data.count > 0 {
            var xmin : Double = .greatestFiniteMagnitude
            var xmax : Double = -.greatestFiniteMagnitude
            var ymin : Double = .greatestFiniteMagnitude
            var ymax : Double = -.greatestFiniteMagnitude
            for (_, line) in data {
                let (x, y) = self.lineToXY(line: line)
                plotdata.append((x, y))
                xmin = min(xmin, x)
                xmax = max(xmax, x)
                ymin = min(ymin, y)
                ymax = max(ymax, y)
            }
            xlim = [xmin, xmax]
            ylim = [ymin, ymax]
            if xlim[0] == xlim[1] {
                xlim[0] -= 0.5
                xlim[1] += 0.5
            }
            if ylim[0] == ylim[1] {
                ylim[0] -= 0.5
                ylim[1] += 0.5
            }
            
            xTicks = calcXTicks(lim: xlim)
            yTicks = calcYTicks(lim: ylim)
            xlim[0] = min(xlim[0], xTicks[0].val)
            xlim[1] = max(xlim[1], xTicks[xTicks.count - 1].val)
            ylim[0] = min(ylim[0], yTicks[0].val)
            ylim[1] = max(ylim[1], yTicks[yTicks.count - 1].val)
            
        }
    }
    
    func lineToXY (line : JSON) -> (x: Double, y: Double) {
        let x : Double = 0
        let y : Double = 0
        return (x, y)
    }
    
    func calcXTicks(lim: [Double]) -> [(Double, String)] {
        return calcTicks(lim: lim)
    }
    
    func calcYTicks(lim: [Double]) -> [(Double, String)] {
        return calcTicks(lim: lim)
    }
    
    func calcTicks(lim: [Double], type: String = "DOUBLE") -> [(Double, String)] {
        var ret : [(Double, String)] = []
        switch (type) {
        case "DATE":
            let startdate = Date(timeIntervalSince1970: lim[0])
            let enddate = Date(timeIntervalSince1970: lim[1])
            let dur = enddate.timeIntervalSince(startdate) / 86400
            //let dur = DateInterval(start: startdate, end: enddate)
            let formatter = DateFormatter()
            var interval : TimeInterval = 86400
            var nextdate = enddate
            if (dur < 12) {
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMM", options: 0, locale: Locale(identifier: "ja_JP"))
                interval = 1 * 86400
            } else if (dur < 100) {
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMM", options: 0, locale: Locale(identifier: "ja_JP"))
                interval = 7 * 86400
            } else {
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: Locale(identifier: "ja_JP"))
                interval = 30 * 86400
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.year, .month], from: enddate)
                nextdate = calendar.date(from: comps)!
            }
            while (startdate < nextdate) {
                ret.append((nextdate.timeIntervalSince1970 as Double, formatter.string(from: nextdate)))
                nextdate = Date(timeInterval: -interval, since: nextdate)
            }
            if (startdate < Date(timeInterval: interval * 0.5, since: nextdate)) {
                ret.append((startdate.timeIntervalSince1970 as Double, formatter.string(from: startdate)))
            }
            ret.reverse()
        case "DOUBLE":
            fallthrough
        default:
            let interval = fitInterval(valueRange: lim[1] - lim[0])
            for i in Int(lim[0] / interval) ..< Int(lim[1] / interval) + 2 {
                let val = interval * Double(i)
                let vals = "\(val)"
                ret.append((val, vals))
            }
        }
        return ret
    }
    
    func fitInterval(valueRange : Double) -> Double {
        var ret : Double = 1.0
        if valueRange <= 0 {
            print("ERROR at \(#file),\(#line),\(#column),\(#function)")
        } else if valueRange < ret {
            while valueRange < ret {
                ret *= 0.1
            }
        } else if valueRange > ret * 10 {
            while valueRange > ret * 10 {
                ret *= 10
            }
        }
        return ret
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("\(#file),\(#line),\(#column),\(#function)")
        let dataSize = plotdata.count
        if dataSize > 0 {
            
            var xrange = xlim[1] - xlim[0]
            var yrange = ylim[1] - ylim[0]
            if xrange <= 0 {
                print("xrange is less than 0")
                xrange = 1.0
            }
            if yrange <= 0 {
                print("yrange is less than 0")
                yrange = 1.0
            }
            
            if let context = UIGraphicsGetCurrentContext() {
                
                let plotrect = plotview.frame
                
                context.setFillColor(UIColor.black.cgColor)
                context.fill(plotrect)
                
                let s : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                s.alignment = .right
                let att = [
                    NSParagraphStyleAttributeName: s,
                    NSFontAttributeName: UIFont(name: "Courier", size: 10.0)!,
                    NSForegroundColorAttributeName: UIColor.black
                ]
                let tickrot : CGFloat = -1
                let tickrect = CGRect(x: -80, y: -5, width: 80, height: 10)
                
                for (xval, xvals) in xTicks {
                    let x = plotrect.origin.x + plotrect.size.width * CGFloat((xval - xlim[0]) / xrange)
                    print("x:\(x), y:\(plotrect.minY) \(plotrect.maxY)")
                    if isPlotGrid {
                        context.setStrokeColor(UIColor.gray.cgColor)
                        context.setLineWidth(3)
                        context.move(to: CGPoint(x: x, y: plotrect.minY))
                        context.addLine(to: CGPoint(x: x, y: plotrect.maxY))
                        context.strokePath()
                    }
                    context.translateBy(x: x, y: plotrect.maxY + 10)
                    context.rotate(by: tickrot)
                    xvals.draw(in: tickrect, withAttributes: att)
                    context.rotate(by: -tickrot)
                    context.translateBy(x: -x, y: -(plotrect.maxY + 10))
                }
                
                for (yval, yvals) in yTicks {
                    let y = plotrect.origin.y + plotrect.size.height - plotrect.size.height * CGFloat((yval - ylim[0]) / yrange)
                    print("x:\(plotrect.minX) \(plotrect.maxX), y:\(y)")
                    if isPlotGrid {
                        context.setStrokeColor(UIColor.gray.cgColor)
                        context.setLineWidth(3)
                        context.move(to: CGPoint(x: plotrect.minX, y: y))
                        context.addLine(to: CGPoint(x: plotrect.maxX, y: y))
                        context.strokePath()
                    }
                    context.translateBy(x: plotrect.minX - 10, y: y)
                    context.rotate(by: tickrot)
                    yvals.draw(in: tickrect, withAttributes: att)
                    context.rotate(by: -tickrot)
                    context.translateBy(x: -(plotrect.minX - 10), y: -y)
                }
                
                context.setStrokeColor(UIColor.green.cgColor)
                context.setFillColor(UIColor.green.cgColor)
                context.setLineWidth(3)
                var isFirst = true
                for (x, y) in self.plotdata {
                    let x2 = plotrect.origin.x + plotrect.size.width * CGFloat((x - xlim[0]) / xrange)
                    let y2 = plotrect.origin.y + plotrect.size.height - plotrect.size.height * CGFloat((y - ylim[0]) / yrange)
                    if isFirst {
                        isFirst = false
                    } else {
                        context.addLine(to: CGPoint(x: x2, y: y2))
                        context.strokePath()
                    }
                    context.fillEllipse(in: CGRect(x: x2 - 2, y: y2 - 2, width: 4, height: 4))
                    context.move(to: CGPoint(x: x2, y: y2))
                }
                
            }
        }
        
    }
    
}
