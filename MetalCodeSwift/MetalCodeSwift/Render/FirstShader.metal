//
//  FirstShader.metal
//  MetalCodeSwift
//
//  Created by aby.wang on 2019/12/4.
//  Copyright © 2019 aby.wang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "FirstShaderShare.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    float4 color;
} RasterizerData;

//顶点着色函数
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
            constant CCVertex *vertices [[buffer(CCVertexInputIndexVertices)]],
            constant vector_uint2 *viewportSizePointer [[buffer(CCVertexInputIndexViewportSize)]]){
    RasterizerData out;
    out.clipSpacePosition = vector_float4(0.0,0.0,0.0,1.0);
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]]){
    return in.color;
}
