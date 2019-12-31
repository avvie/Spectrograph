Shader "Custom/NewImageEffectShader"
{
    Properties
    {
        _MainTex1 ("Tex1", 2D) = "black" {}
        _MainTex2 ("Tex2", 2D) = "black" {}
        _data ("Tex3", 2D) = "white" {}
        _height ("height", float)= 800
        Hf ("Hue factor", Range(0.0, 9000.0)) = 0
        H ("Hue", Range(0.0, 360.0)) = 0
        S ("Saturation", Range(0.0, 1.0)) = 1.0
        V ("Value", Range(0.0, 1.0)) = 1.0
        XOffset("xOffset", Range(-100,100)) = 0
        YOffset("yOffset", Range(0,800)) = 40
        XOffsetFactor("XOffsetFactor", Range(-30, 21000)) = 1
        magnitudeScale("magnitudeScale", Range(1,21000)) = 1
        magnitudeOffset("magnitudeOffset", Range(1,9000)) = 1
        alphaDrop("AlphaDrop", Range(0,1)) = 0.89
        check("peaksOnly", Range(0,1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #include "UnityCG.cginc"
            #include "ImageEffectVertex.cginc"

            sampler2D _MainTex1;
            sampler2D _MainTex2;
            sampler2D _data;
            float _height;
            float Hf;
            float H;
            float S;
            float V;
            float4 _MainTex1_TexelSize;
            float XOffset;
            float YOffset;
            float XOffsetFactor;
            float magnitudeScale;
            float alphaDrop;
            float check;
            float magnitudeOffset;
                        
            float plot(float2 xy, float y){
                return smoothstep( y-0.02, y, xy.y) - smoothstep( y, y+0.02, xy.y);
            }

            float applyLinearTransform(float2 xy){
                return xy.x;
            }

            ////////////
            float K(int n, float H){
                return glslmod((n + H/60), 6);
            }
            
            float MinMax(float k){
                return max(min( min(k, 4-k) ,1),0);
            }
            
            float F(int n, float3 c){
                return c.z * (1 - c.y * MinMax(K(n, c.x)));
            }
            float3 hsv2rgb(float3 c) {
              c.yz = clamp(c.yz, 0,1);
              float3 col;
              col.x = F(5,c);
              col.y = F(3,c);
              col.z = F(1,c);
              
              
              return col;
            }

            float4 FragmentProgram(Interpolators i) : SV_Target{
                float y = applyLinearTransform(i.screenPos);
                float2 pos = screenSpaceConversion(i.screenPos);
                float logx = log(pos.x)*XOffsetFactor;
                float4 color = y;

                float3 dat = tex2D(_data, float2(logx, 1));
                float magnitude = length(dat);
                float newXOffset = H + XOffset + magnitude * magnitudeOffset;
                color = tex2D(_MainTex1, float2(pos.x - _MainTex1_TexelSize.x * newXOffset, pos.y - _MainTex1_TexelSize.y * YOffset));
             
                if(magnitude*magnitudeScale > pos.y && (magnitude*magnitudeScale < pos.y+check)){
                    //color = normalize(dat); 
                    
                    //color.yz = 0.4;
                    //color.x = 1;
                    
                    //float3 color = hsv2rgb(float3(magnitude*Hf + H, S, V));
                    float3 color = hsv2rgb(float3(pos.x*Hf + _Time.w * H, S, V));
                    
                    //color = normalize(dat);
                    //color.x *= (1 - pos.x);
                    //color.y *= (1 - pos.y);
                    //color.z *= (1 - pos.x)*(1 - pos.y);
                    return float4(color, 1);
                    //return float4(normalize(color), 1);
                    //return finalColor;           
                }   
                
                if(magnitude + _MainTex1_TexelSize.y * YOffset > pos.y){
                    return float4(0,0,0,1);
                }
                // color = pct;
                //color = float3(0.8,0.8,0.8);
              
                //color = normalize(color);
                //color.x *= (1 - pos.x);
                //color.y *= (1 - pos.y);
                //color.z *= (1 - pos.x)*(1 - pos.y);
                //return float4(0,0,0,alphaDrop);
                return color;
            }
            ENDCG
        }
    }
}
