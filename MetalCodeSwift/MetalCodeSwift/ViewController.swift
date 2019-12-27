//
//  ViewController.swift
//  MetalCodeSwift
//
//  Created by aby.wang on 2019/11/20.
//  Copyright © 2019 aby.wang. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    let mtView = MTKView.init(frame: UIScreen.main.bounds)
    var render: AbyRender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtView.device = MTLCreateSystemDefaultDevice()
        let render = AbyRender.init(mtkView: mtView)
        mtView.preferredFramesPerSecond = 60
        render.mtkView(mtView, drawableSizeWillChange: mtView.drawableSize)
        // Do any additional setup after loading the view.
        mtView.delegate = render
        self.render = render
        view.addSubview(mtView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
