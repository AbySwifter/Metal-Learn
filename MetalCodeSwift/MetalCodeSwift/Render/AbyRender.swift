//
//  AbyRender.swift
//  MetalCodeSwift
//
//  Created by aby.wang on 2019/11/20.
//  Copyright © 2019 aby.wang. All rights reserved.
//

import Foundation
import MetalKit


class AbyRender:NSObject, MTKViewDelegate {
    
    struct ABYColor {
        var red: Double
        var green: Double
        var blue: Double
        var alpha: Double
    }
    
    var device: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var viewportSize: vector_uint2 = vector_uint2()
    var pipLineState: MTLRenderPipelineState?
    
    private var growing: Bool = true
    private var primaryChannel: Int = 0
    private var colorChannels: [Double] = [1.0, 0.0, 0.0, 1.0]
    private let dynamicclorRate = 0.015
    
    override init() { super.init() }
    
    init(mtkView: MTKView) {
        device = mtkView.device
        commandQueue = mtkView.device?.makeCommandQueue()
        let defaultLibrary = device?.makeDefaultLibrary()
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor.init()
        pipelineStateDescriptor.label = "Simple Pipline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        do {
            pipLineState = try device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        commandQueue = device?.makeCommandQueue()
        super.init()
    }
    // MARK: - MTKViewDelegate
    
    /// 视图大小发生变化时调用
    /// - Parameter view: 视图
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.width)
    }
    
    /// 视图需要渲染时调用
    /// - Parameters:
    ///   - view: 视图
    ///   - size: 大小
    func draw(in view: MTKView) {
        guard let state = pipLineState else { return }
        let triangleVertices = [
            CCVertex.init(position: [250, -250], color: [1, 0, 0, 1]),
            CCVertex.init(position: [-250, -250], color: [0, 1, 0, 1]),
            CCVertex.init(position: [250, 250], color: [0, 0, 1, 1])
        ]
        if let commandBuffer = commandQueue?.makeCommandBuffer() {
            commandBuffer.label = "MyCommand"
            if let renderPassDescriptor = view.currentRenderPassDescriptor {
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                renderEncoder?.label = "MyRenderEncoder"
                let viewPort: MTLViewport = MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1.0, zfar: 1.0)
                renderEncoder?.setViewport(viewPort)
                renderEncoder?.setRenderPipelineState(state)
                renderEncoder?.setVertexBytes(triangleVertices, length: MemoryLayout<CCVertex>.size * 3, index: Int(CCVertexInputIndexVertices.rawValue))
                renderEncoder?.setVertexBytes(&viewportSize, length: MemoryLayout<vector_uint2>.size, index: Int(CCVertexInputIndexViewportSize.rawValue))
                renderEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
                renderEncoder?.endEncoding()
                if let drawable = view.currentDrawable {
                    commandBuffer.present(drawable)
                }
            }
            commandBuffer.commit()
        }
    }
    
    func makeColor() -> ABYColor {
        if growing {
            let dynamicChannelIndex = (primaryChannel + 1) % 3
            colorChannels[dynamicChannelIndex] += dynamicclorRate
            if colorChannels[dynamicChannelIndex] >= 1.0 {
                growing = false
                primaryChannel = dynamicChannelIndex
            }
        } else {
            let dynamicChannelIndex = (primaryChannel + 2) % 3
            colorChannels[dynamicChannelIndex] -= dynamicclorRate
            if colorChannels[dynamicChannelIndex] <= 0 {
                growing = true
            }
        }
        return ABYColor.init(red: colorChannels[0], green: colorChannels[1], blue: colorChannels[2], alpha: colorChannels[3])
    }
    
    struct CCVertex{
        var position: vector_float2
        let color: vector_float4
    }
    
    class func generateVertexData() -> Data{
        let quadVertices: Array<CCVertex> = [
            CCVertex.init(position: vector_float2.init(x: -20, y: 20), color: vector_float4.init(1, 0, 0, 1)),
            CCVertex.init(position: vector_float2.init(x: 20, y: 20), color: vector_float4.init(1, 0, 0, 1)),
            CCVertex.init(position: vector_float2.init(x: -20, y: -20), color: vector_float4.init(1, 0, 0, 1)),
            CCVertex.init(position: vector_float2.init(x: 20, y: -20), color: vector_float4.init(0, 0, 1, 1)),
            CCVertex.init(position: vector_float2.init(x: -20, y: -20), color: vector_float4.init(0, 0, 1, 1)),
            CCVertex.init(position: vector_float2.init(x: 20, y: 20), color: vector_float4.init(0, 0, 1, 1))
        ]
        //行/列 数量
        let NUM_COLUMNS = 25
        let NUM_ROWS = 15
        //顶点个数
        let NUM_VERTICES_PER_QUAD = quadVertices.count
        //四边形间距
        let QUAD_SPACING: Float32 = 50.0
        let pointer = UnsafeMutablePointer<CCVertex>.allocate(capacity: NUM_VERTICES_PER_QUAD * NUM_COLUMNS * NUM_ROWS)
        var pointerPosition = 0
        for row in 0..<NUM_ROWS{
            for column in 0..<NUM_COLUMNS{
                //A.左上角的位置
                let upperLeftPosition: vector_float2
                //B.计算X,Y 位置.注意坐标系基于2D笛卡尔坐标系,中心点(0,0),所以会出现负数位置
                let x: Float32 = ((Float32(-NUM_COLUMNS) / 2.0) + Float32(column)) * QUAD_SPACING + QUAD_SPACING / 2.0
                let y: Float32 = ((Float32(-NUM_ROWS) / 2.0) + Float32(row)) * QUAD_SPACING + QUAD_SPACING / 2.0
                upperLeftPosition = vector_float2.init(x: x, y: y)
                //C.将quadVertices数据复制到currentQuad
                for i in 0..<NUM_VERTICES_PER_QUAD{
                    pointer[pointerPosition + i] = quadVertices[i]
                }
                //D.遍历currentQuad中的数据
                for vertexInQuad in 0..<NUM_VERTICES_PER_QUAD{
                    pointer[pointerPosition + vertexInQuad].position += upperLeftPosition
                }
                pointerPosition += NUM_VERTICES_PER_QUAD
            }
        }
        return Data.init(bytes: pointer, count: NUM_VERTICES_PER_QUAD * NUM_COLUMNS * NUM_ROWS * 3)
    }
}
