// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/TexturedShine"
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
		[Toggle]_Enable("Enable", Float) = 1
		_ShineTexture("ShineTexture", 2D) = "white" {}
		_XSpeed("XSpeed", Range( -1 , 1)) = 0.5
		[KeywordEnum(Simple,Sliced)] _ImageType("ImageType", Float) = 0
		_ShineColor("ShineColor", Color) = (1,1,1,1)
		_YSpeed("YSpeed", Range( -1 , 1)) = 0.5
		_ShineMask("ShineMask", 2D) = "white" {}
		_Glow("Glow", Range( -2 , 2)) = 0
		[KeywordEnum(Overlay,Additive)] _Blending("Blending", Float) = 0
		_Delay("Delay", Float) = 0
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
			
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _BLENDING_OVERLAY _BLENDING_ADDITIVE
			#pragma shader_feature_local _IMAGETYPE_SIMPLE _IMAGETYPE_SLICED

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord3 : TEXCOORD3;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float _Enable;
			uniform float4 _MainTex_ST;
			uniform float4 _ShineColor;
			uniform float _Glow;
			uniform sampler2D _ShineTexture;
			uniform float4 _ShineTexture_ST;
			uniform float _XSpeed;
			uniform float _Delay;
			uniform float _YSpeed;
			uniform sampler2D _ShineMask;
			uniform float4 _ShineMask_ST;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				OUT.ase_texcoord2.xy = IN.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord2.zw = 0;
				
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

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode28 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_180_0 = ( tex2DNode28 * IN.color );
				float3 temp_output_9_0_g2 = _ShineColor.rgb;
				float3 hsvTorgb3_g2 = RGBToHSV( temp_output_9_0_g2 );
				float3 hsvTorgb6_g2 = HSVToRGB( float3(hsvTorgb3_g2.x,hsvTorgb3_g2.y,( hsvTorgb3_g2.z + _Glow )) );
				float4 appendResult218 = (float4(( temp_output_9_0_g2 * hsvTorgb6_g2 ) , _ShineColor.a));
				float temp_output_247_0 = ( 1.0 / abs( _XSpeed ) );
				float temp_output_15_0_g3 = _Delay;
				float temp_output_6_0_g3 = ( _Time.y % ( temp_output_247_0 + temp_output_15_0_g3 ) );
				float temp_output_248_0 = ( 1.0 / abs( _YSpeed ) );
				float temp_output_15_0_g4 = _Delay;
				float temp_output_6_0_g4 = ( _Time.y % ( temp_output_248_0 + temp_output_15_0_g4 ) );
				float2 appendResult262 = (float2(( sign( _XSpeed ) * (-1.0 + (( ( temp_output_6_0_g3 >= temp_output_15_0_g3 ? temp_output_6_0_g3 : 0.0 ) - temp_output_15_0_g3 ) - 0.0) * (1.0 - -1.0) / (temp_output_247_0 - 0.0)) ) , ( (-1.0 + (( ( temp_output_6_0_g4 >= temp_output_15_0_g4 ? temp_output_6_0_g4 : 0.0 ) - temp_output_15_0_g4 ) - 0.0) * (1.0 - -1.0) / (temp_output_248_0 - 0.0)) * sign( _YSpeed ) )));
				float2 temp_output_193_0 = ( _ShineTexture_ST.zw + ( appendResult262 * -1 ) );
				float2 texCoord147 = IN.texcoord.xy * _ShineTexture_ST.xy + temp_output_193_0;
				float2 texCoord124 = IN.ase_texcoord2.xy * _ShineTexture_ST.xy + temp_output_193_0;
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch146 = texCoord147;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch146 = texCoord124;
				#else
				float2 staticSwitch146 = texCoord147;
				#endif
				float4 tex2DNode91 = tex2D( _ShineTexture, staticSwitch146 );
				float4 temp_output_183_0 = ( appendResult218 * tex2DNode91 );
				float4 blendOpSrc211 = temp_output_183_0;
				float4 blendOpDest211 = temp_output_180_0;
				float2 uv_ShineMask = IN.texcoord.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				float2 uv4_ShineMask = IN.ase_texcoord2.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch199 = uv_ShineMask;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch199 = uv4_ShineMask;
				#else
				float2 staticSwitch199 = uv_ShineMask;
				#endif
				float temp_output_184_0 = ( _ShineColor.a * tex2DNode91.a * tex2D( _ShineMask, staticSwitch199 ).a * tex2DNode28.a );
				float4 lerpBlendMode211 = lerp(blendOpDest211,(( blendOpDest211 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest211 ) * ( 1.0 - blendOpSrc211 ) ) : ( 2.0 * blendOpDest211 * blendOpSrc211 ) ),temp_output_184_0);
				float4 blendOpSrc214 = temp_output_183_0;
				float4 blendOpDest214 = temp_output_180_0;
				float4 lerpBlendMode214 = lerp(blendOpDest214,( blendOpSrc214 + blendOpDest214 ),temp_output_184_0);
				#if defined(_BLENDING_OVERLAY)
				float4 staticSwitch212 = lerpBlendMode211;
				#elif defined(_BLENDING_ADDITIVE)
				float4 staticSwitch212 = ( saturate( lerpBlendMode214 ));
				#else
				float4 staticSwitch212 = lerpBlendMode211;
				#endif
				float4 appendResult177 = (float4(staticSwitch212.rgb , (temp_output_180_0).a));
				
				half4 color = (( _Enable )?( appendResult177 ):( temp_output_180_0 ));
				
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
	CustomEditor "TexturedShineShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
303;487;1112;519;1496.356;-1423.987;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;186;-1241.884,1769.878;Inherit;False;Property;_YSpeed;YSpeed;5;0;Create;True;0;0;0;False;0;False;0.5;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-1253.655,1440.063;Inherit;False;Property;_XSpeed;XSpeed;2;0;Create;True;0;0;0;False;0;False;0.5;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;250;-942.7458,1777.18;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;251;-955.1936,1444.236;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;261;-948.2505,1877.429;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;257;-979.8221,1385.173;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;248;-796.8843,1755.725;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;247;-808.8252,1421.32;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;266;-814.3121,1519.073;Inherit;False;Property;_Delay;Delay;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;227;-864.5219,1597.187;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SignOpNode;258;-443.8822,1891.518;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;280;-536.3389,1455.016;Inherit;False;DelayedRemapper;-1;;3;9a813013bc16c4a8d875950108b5fb21;0;7;15;FLOAT;0;False;4;FLOAT;0;False;3;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;-1;False;14;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;281;-538.2955,1679.241;Inherit;False;DelayedRemapper;-1;;4;9a813013bc16c4a8d875950108b5fb21;0;7;15;FLOAT;0;False;4;FLOAT;0;False;3;FLOAT;0;False;11;FLOAT;0;False;12;FLOAT;0;False;13;FLOAT;-1;False;14;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;254;-445.0242,1382.933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-251.2168,1432.934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-252.2166,1681.622;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;262;-56.97966,1534.264;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;264;-67.61902,1645.988;Inherit;False;Constant;_Int0;Int 0;8;0;Create;True;0;0;0;False;0;False;-1;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;91.98888,1536.036;Inherit;False;2;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;192;32.73737,1325.05;Inherit;False;91;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;193;236.7369,1440.05;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;535.1754,1795.165;Inherit;False;3;198;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;219;1033.325,1065.707;Inherit;False;Property;_Glow;Glow;7;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;551.1777,1439.415;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;182;1102.363,1156.097;Inherit;False;Property;_ShineColor;ShineColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;548.917,1312.288;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;201;533.1754,1664.165;Inherit;False;0;198;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;216;1321.407,1161.45;Inherit;False;AddBrightnessToColor;-1;;2;74d7e655a5e1c4e75ac14bf3ca74e7c2;0;2;9;FLOAT3;0,0,0;False;11;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;199;800.1754,1699.165;Inherit;False;Property;_Keyword0;Keyword 0;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;146;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;116;881.6473,1936.634;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;146;795.917,1354.288;Inherit;False;Property;_ImageType;ImageType;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Simple;Sliced;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;218;1587.05,1196.48;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;198;1024.175,1667.165;Inherit;True;Property;_ShineMask;ShineMask;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;179;1167.545,2128.999;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;91;1020.764,1330.805;Inherit;True;Property;_ShineTexture;ShineTexture;1;0;Create;True;0;0;0;False;0;False;-1;None;e2317eb2d2d9d481b9ada5dd424268ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;1041.178,1934.318;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;6dc9c112f83364b87a64dc2c46c4c6d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;1432.413,1940.019;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1738.185,1241.351;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;1392.613,1526.018;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;211;1952.225,1237.184;Inherit;False;Overlay;False;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;214;1945.819,1412.396;Inherit;False;LinearDodge;True;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;181;1899.258,1932.569;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;212;2210.899,1325.213;Inherit;False;Property;_Blending;Blending;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Overlay;Additive;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;177;2483.577,1330.349;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ToggleSwitchNode;265;2693.68,1573.921;Inherit;False;Property;_Enable;Enable;0;0;Create;True;0;0;0;False;0;False;1;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;115;2915.778,1577.731;Float;False;True;-1;2;TexturedShineShaderEditor;0;6;mrvc/TexturedShine;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;250;0;186;0
WireConnection;251;0;189;0
WireConnection;261;0;186;0
WireConnection;257;0;189;0
WireConnection;248;1;250;0
WireConnection;247;1;251;0
WireConnection;258;0;261;0
WireConnection;280;15;266;0
WireConnection;280;4;247;0
WireConnection;280;3;227;2
WireConnection;280;12;247;0
WireConnection;281;15;266;0
WireConnection;281;4;248;0
WireConnection;281;3;227;2
WireConnection;281;12;248;0
WireConnection;254;0;257;0
WireConnection;255;0;254;0
WireConnection;255;1;280;0
WireConnection;259;0;281;0
WireConnection;259;1;258;0
WireConnection;262;0;255;0
WireConnection;262;1;259;0
WireConnection;263;0;262;0
WireConnection;263;1;264;0
WireConnection;193;0;192;1
WireConnection;193;1;263;0
WireConnection;124;0;192;0
WireConnection;124;1;193;0
WireConnection;147;0;192;0
WireConnection;147;1;193;0
WireConnection;216;9;182;0
WireConnection;216;11;219;0
WireConnection;199;1;201;0
WireConnection;199;0;200;0
WireConnection;146;1;147;0
WireConnection;146;0;124;0
WireConnection;218;0;216;0
WireConnection;218;3;182;4
WireConnection;198;1;199;0
WireConnection;91;1;146;0
WireConnection;28;0;116;0
WireConnection;180;0;28;0
WireConnection;180;1;179;0
WireConnection;183;0;218;0
WireConnection;183;1;91;0
WireConnection;184;0;182;4
WireConnection;184;1;91;4
WireConnection;184;2;198;4
WireConnection;184;3;28;4
WireConnection;211;0;183;0
WireConnection;211;1;180;0
WireConnection;211;2;184;0
WireConnection;214;0;183;0
WireConnection;214;1;180;0
WireConnection;214;2;184;0
WireConnection;181;0;180;0
WireConnection;212;1;211;0
WireConnection;212;0;214;0
WireConnection;177;0;212;0
WireConnection;177;3;181;0
WireConnection;265;0;180;0
WireConnection;265;1;177;0
WireConnection;115;0;265;0
ASEEND*/
//CHKSM=806FD1C03FE87C710B5EEAD1C6B98D27D6B60097