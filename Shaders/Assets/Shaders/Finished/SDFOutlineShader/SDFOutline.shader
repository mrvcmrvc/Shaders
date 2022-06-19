// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/SDFOutline"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		[HDR]_InnerGlowColor("InnerGlowColor", Color) = (2.118547,0.9760846,0,1)
		_OutlineTexture("OutlineTexture", 2D) = "white" {}
		_InnerWidth("InnerWidth", Range( 0 , 1)) = 0
		_InnerSmoothness("InnerSmoothness", Range( 0 , 1)) = 0
		[HDR]_OuterGlowColor("OuterGlowColor", Color) = (2.118547,0.9760846,0,1)
		_OuterWidth("OuterWidth", Range( 0 , 1)) = 1
		_OuterSmoothness("OuterSmoothness", Range( 0 , 1)) = 0
		_Blend("Blend", Range( 0 , 1)) = 0
		_BlendWidth("BlendWidth", Range( 0 , 1)) = 0
		_SpriteEdgeAlpha("SpriteEdgeAlpha", Range( 0 , 1)) = 0.525
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float _OuterWidth;
			uniform float _SpriteEdgeAlpha;
			uniform float _OuterSmoothness;
			uniform sampler2D _OutlineTexture;
			uniform float4 _OutlineTexture_ST;
			uniform float4 _OuterGlowColor;
			uniform float4 _InnerGlowColor;
			uniform float _BlendWidth;
			uniform float _Blend;
			uniform float4 _MainTex_ST;
			uniform float _InnerWidth;
			uniform float _InnerSmoothness;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float clampResult517 = clamp( _SpriteEdgeAlpha , 0.001 , 0.999 );
				float temp_output_71_0 = ( ( 1.0 - _OuterWidth ) * clampResult517 );
				float lerpResult72 = lerp( temp_output_71_0 , clampResult517 , _OuterSmoothness);
				float2 uv_OutlineTexture = IN.texcoord.xy * _OutlineTexture_ST.xy + _OutlineTexture_ST.zw;
				float smoothstepResult6 = smoothstep( temp_output_71_0 , lerpResult72 , tex2D( _OutlineTexture, uv_OutlineTexture ).a);
				float4 appendResult25 = (float4(1.0 , 1.0 , 1.0 , smoothstepResult6));
				float4 temp_output_293_0 = ( ( _OuterGlowColor + _InnerGlowColor ) * float4( 1,1,1,0.5019608 ) );
				float4 tex2DNode359 = tex2D( _OutlineTexture, uv_OutlineTexture );
				float smoothstepResult360 = smoothstep( ( ( 1.0 - _BlendWidth ) * clampResult517 ) , clampResult517 , tex2DNode359.a);
				float lerpResult365 = lerp( _BlendWidth , 1.0 , clampResult517);
				float smoothstepResult361 = smoothstep( clampResult517 , lerpResult365 , tex2DNode359.a);
				float lerpResult218 = lerp( step( clampResult517 , tex2D( _OutlineTexture, uv_OutlineTexture ).a ) , ( ( smoothstepResult360 + smoothstepResult361 ) * 0.5 ) , _Blend);
				float4 lerpResult247 = lerp( ( appendResult25 * _OuterGlowColor ) , temp_output_293_0 , lerpResult218);
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float lerpResult81 = lerp( _InnerWidth , 1.0 , clampResult517);
				float lerpResult82 = lerp( lerpResult81 , clampResult517 , max( _InnerSmoothness , 0.001 ));
				float smoothstepResult48 = smoothstep( lerpResult82 , lerpResult81 , tex2D( _OutlineTexture, uv_OutlineTexture ).a);
				float4 lerpResult76 = lerp( _InnerGlowColor , tex2D( _MainTex, uv_MainTex ) , smoothstepResult48);
				float4 appendResult352 = (float4((lerpResult76).rgb , 1.0));
				float4 lerpResult226 = lerp( temp_output_293_0 , appendResult352 , lerpResult218);
				float4 lerpResult104 = lerp( lerpResult247 , lerpResult226 , lerpResult218);
				float4 tex2DNode391 = tex2D( _MainTex, uv_MainTex );
				float smoothstepResult509 = smoothstep( 0.0 , 0.0 , tex2DNode391.a);
				float4 appendResult492 = (float4(( ( (lerpResult104).xyz * ( 1.0 - smoothstepResult509 ) ) + (tex2DNode391).rgb ) , tex2DNode391.a));
				float temp_output_399_0 = (lerpResult104).w;
				float4 appendResult436 = (float4(1.0 , 1.0 , 1.0 , ( 1.0 - ( ( 1.0 - temp_output_399_0 ) * tex2DNode391.a ) )));
				float4 lerpResult439 = lerp( appendResult492 , ( appendResult436 * lerpResult104 ) , temp_output_399_0);
				
				half4 color = lerpResult439;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
116;-1305;1831;1211;4971.439;2106.644;4.553793;True;False
Node;AmplifyShaderEditor.RangedFloatNode;83;-2718.177,532.0973;Inherit;False;Property;_SpriteEdgeAlpha;SpriteEdgeAlpha;9;0;Create;True;0;0;0;False;0;False;0.525;0.525;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;517;-2453.2,537.0722;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.999;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;527;-2246.353,1475.85;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;531;-2038.011,430.4967;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1789.076,-150.0913;Inherit;False;Property;_OuterWidth;OuterWidth;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-1209.559,764.6159;Inherit;False;Property;_BlendWidth;BlendWidth;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-1652.889,1545.883;Inherit;False;Property;_InnerWidth;InnerWidth;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;526;-1877.188,1605.607;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;529;-2233.559,766.765;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;519;-2257.155,14.61704;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1538.689,1762.277;Inherit;False;Property;_InnerSmoothness;InnerSmoothness;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;525;-2299.352,1600.123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;234;-1223.427,1747.107;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;530;-1387.405,600.4584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-1519.076,-145.0913;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;528;-1520.816,896.5198;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;-2100.266,885.7876;Inherit;False;Property;_InnerGlowColor;InnerGlowColor;0;1;[HDR];Create;True;0;0;0;False;0;False;2.118547,0.9760846,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;524;-1617.676,1702.467;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;518;-1780.845,-65.83193;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;-1285.713,1549.751;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.525;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;363;-959.7045,556.4229;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;521;-2186.918,68.24986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1499.076,23.90899;Inherit;False;Property;_OuterSmoothness;OuterSmoothness;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;82;-1092.012,1672.22;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.525;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-820.5582,555.5072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.525;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;359;-980.8307,320.7645;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;248;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;533;-870.2109,722.9041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;320;-1335.099,1175.667;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1360.075,-116.0913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.525;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;532;-866.5558,721.0756;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;250;-1426.736,1353.536;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;248;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;365;-834.3784,827.4071;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.525;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;520;-1755.306,-7.091354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-2115.085,516.0495;Inherit;False;Property;_OuterGlowColor;OuterGlowColor;4;1;[HDR];Create;True;0;0;0;False;0;False;2.118547,0.9760846,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;61;-1023.827,1256.504;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;523;-2098.321,344.6024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;251;-790.3467,1183.055;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;249;-1323.745,-353.4247;Inherit;True;Property;_TextureSample6;Texture Sample 6;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;248;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;360;-655.6515,577.1011;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;72;-1183.075,-53.09122;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.525;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;48;-904.637,1512.709;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;361;-654.3885,719.8455;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;6;-1027.936,-179.4886;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-1877.407,707.0232;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;522;-270.7774,276.9832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;252;-487.0087,436.5334;Inherit;True;Property;_TextureSample7;Texture Sample 7;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;248;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;301;-458.0871,652.3808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;76;-587.0325,1348.387;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;232;-1151.143,115.4536;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;302;-201.6789,653.8973;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-834.0912,-197.5709;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;351;-424.3412,1344.893;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-295.3159,804.2975;Inherit;False;Property;_Blend;Blend;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1751.347,707.9678;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0.5019608;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;79;-163.8232,407.7341;Inherit;False;2;0;FLOAT;0.525;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;355;-1062.066,230.7533;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;353;-1147.73,1052.058;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;352;-220.3412,1350.893;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-540.0322,-55.5864;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;218;9.834607,629.8829;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;226;293.9763,1084.72;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;247;306.2354,100.6582;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;104;511.1718,536.8757;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;391;502.6646,779.5473;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;410;836.4321,513.7559;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;510;876.7964,562.4045;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;399;952.1887,416.9171;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;408;1148.189,421.9171;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;509;863.0491,959.3069;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;511;1173.796,525.4045;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;490;1018.156,958.1486;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;409;1297.189,470.9171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;494;976.6686,789.762;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;489;979.1099,864.1516;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;495;826.7827,1082.037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;1232.207,795.6398;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;434;1425.734,471.4086;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;496;1471.883,1051.537;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;1393.743,844.6387;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;436;1585.194,399.8083;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;497;1150.306,701.072;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;460;1687.808,556.4558;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;1756.259,419.0396;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;498;1753.941,753.5089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;492;1568.133,920.2493;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;4;-2652.188,245.4913;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;6c19b129598a84f26887eb3207f3e1dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;439;1988.833,683.2271;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;248;-2654.839,52.97833;Inherit;True;Property;_OutlineTexture;OutlineTexture;1;0;Create;True;0;0;0;False;0;False;-1;None;3fc0cb4b462444c8099921d352c8e283;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;3;-2818.188,249.4913;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;538;2257.319,684.5266;Float;False;True;-1;2;ASEMaterialInspector;0;6;mrvc/SDFOutline;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;517;0;83;0
WireConnection;527;0;517;0
WireConnection;531;0;517;0
WireConnection;526;0;527;0
WireConnection;529;0;517;0
WireConnection;519;0;517;0
WireConnection;525;0;517;0
WireConnection;234;0;46;0
WireConnection;530;0;531;0
WireConnection;70;0;68;0
WireConnection;528;0;529;0
WireConnection;524;0;525;0
WireConnection;518;0;519;0
WireConnection;81;0;47;0
WireConnection;81;2;526;0
WireConnection;363;0;362;0
WireConnection;521;0;517;0
WireConnection;82;0;81;0
WireConnection;82;1;524;0
WireConnection;82;2;234;0
WireConnection;364;0;363;0
WireConnection;364;1;530;0
WireConnection;533;0;517;0
WireConnection;320;0;60;0
WireConnection;71;0;70;0
WireConnection;71;1;518;0
WireConnection;532;0;517;0
WireConnection;365;0;362;0
WireConnection;365;2;528;0
WireConnection;520;0;521;0
WireConnection;523;0;517;0
WireConnection;251;0;320;0
WireConnection;360;0;359;4
WireConnection;360;1;364;0
WireConnection;360;2;532;0
WireConnection;72;0;71;0
WireConnection;72;1;520;0
WireConnection;72;2;73;0
WireConnection;48;0;250;4
WireConnection;48;1;82;0
WireConnection;48;2;81;0
WireConnection;361;0;359;4
WireConnection;361;1;533;0
WireConnection;361;2;365;0
WireConnection;6;0;249;4
WireConnection;6;1;71;0
WireConnection;6;2;72;0
WireConnection;236;0;10;0
WireConnection;236;1;60;0
WireConnection;522;0;523;0
WireConnection;301;0;360;0
WireConnection;301;1;361;0
WireConnection;76;0;251;0
WireConnection;76;1;61;0
WireConnection;76;2;48;0
WireConnection;232;0;10;0
WireConnection;302;0;301;0
WireConnection;25;3;6;0
WireConnection;351;0;76;0
WireConnection;293;0;236;0
WireConnection;79;0;522;0
WireConnection;79;1;252;4
WireConnection;355;0;293;0
WireConnection;353;0;293;0
WireConnection;352;0;351;0
WireConnection;11;0;25;0
WireConnection;11;1;232;0
WireConnection;218;0;79;0
WireConnection;218;1;302;0
WireConnection;218;2;219;0
WireConnection;226;0;353;0
WireConnection;226;1;352;0
WireConnection;226;2;218;0
WireConnection;247;0;11;0
WireConnection;247;1;355;0
WireConnection;247;2;218;0
WireConnection;104;0;247;0
WireConnection;104;1;226;0
WireConnection;104;2;218;0
WireConnection;410;0;104;0
WireConnection;510;0;391;4
WireConnection;399;0;410;0
WireConnection;408;0;399;0
WireConnection;509;0;391;4
WireConnection;511;0;510;0
WireConnection;490;0;509;0
WireConnection;409;0;408;0
WireConnection;409;1;511;0
WireConnection;494;0;104;0
WireConnection;489;0;391;0
WireConnection;495;0;391;4
WireConnection;493;0;494;0
WireConnection;493;1;490;0
WireConnection;434;0;409;0
WireConnection;496;0;495;0
WireConnection;491;0;493;0
WireConnection;491;1;489;0
WireConnection;436;3;434;0
WireConnection;497;0;399;0
WireConnection;460;0;104;0
WireConnection;449;0;436;0
WireConnection;449;1;460;0
WireConnection;498;0;497;0
WireConnection;492;0;491;0
WireConnection;492;3;496;0
WireConnection;4;0;3;0
WireConnection;439;0;492;0
WireConnection;439;1;449;0
WireConnection;439;2;498;0
WireConnection;538;0;439;0
ASEEND*/
//CHKSM=8650969C81DE47185C3BBC32604B0881F09D49C9