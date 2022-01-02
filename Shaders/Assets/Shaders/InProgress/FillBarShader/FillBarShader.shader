// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/FillBarShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		[KeywordEnum(Simple,Sliced)] _ImageType("ImageType", Float) = 0
		_EdgeAngle("Edge Angle", Range( -90 , 90)) = 0
		_LeftOffset("Left Offset", Float) = 0
		_RightOffset("Right Offset", Float) = 0
		[KeywordEnum(2over3,3over2)] _DrawOrder("Draw Order", Float) = 1
		_BarMinPoint1("Bar Min Point 1", Range( 0 , 1)) = 0
		_BarMaxPoint1("Bar Max Point 1", Range( 0 , 1)) = 0.5
		_BarTexture2("Bar Texture 2", 2D) = "white" {}
		_BarColor2("Bar Color 2", Color) = (1,1,1,1)
		_BarMinPoint2("Bar Min Point 2", Range( 0 , 1)) = 0.5
		_BarMaxPoint2("Bar Max Point 2", Range( 0 , 1)) = 0.6
		_BarTexture3("Bar Texture 3", 2D) = "white" {}
		_BarColor3("Bar Color 3", Color) = (1,1,1,1)
		_BarMinPoint3("Bar Min Point 3", Range( 0 , 1)) = 0.4
		_BarMaxPoint3("Bar Max Point 3", Range( 0 , 1)) = 0.6
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _IMAGETYPE_SIMPLE _IMAGETYPE_SLICED
			#pragma shader_feature_local _DRAWORDER_2OVER3 _DRAWORDER_3OVER2


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
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float4 _MainTex_ST;
			uniform float _BarMaxPoint1;
			uniform float _LeftOffset;
			uniform float _RightOffset;
			uniform float _EdgeAngle;
			uniform float _BarMinPoint1;
			uniform sampler2D _BarTexture2;
			uniform float4 _BarTexture2_ST;
			uniform float4 _BarColor2;
			uniform float _BarMaxPoint2;
			uniform float _BarMinPoint2;
			uniform sampler2D _BarTexture3;
			uniform float4 _BarTexture3_ST;
			uniform float4 _BarColor3;
			uniform float _BarMaxPoint3;
			uniform float _BarMinPoint3;
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.ase_texcoord1.xy = IN.ase_texcoord3.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord1.zw = 0;
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode243 = tex2D( _MainTex, uv_MainTex );
				float temp_output_23_0_g14 = _LeftOffset;
				float temp_output_27_0_g14 = ( _RightOffset + 1.0 );
				float temp_output_9_0_g14 = (temp_output_23_0_g14 + (_BarMaxPoint1 - 0.0) * (temp_output_27_0_g14 - temp_output_23_0_g14) / (1.0 - 0.0));
				float2 texCoord103 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord102 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch104 = texCoord103;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch104 = texCoord102;
				#else
				float2 staticSwitch104 = texCoord103;
				#endif
				float3 rotatedValue65 = RotateAroundAxis( float3( 0.5,0.5,0 ), float3( staticSwitch104 ,  0.0 ), float3( 0,0,1 ), radians( _EdgeAngle ) );
				float temp_output_21_0_g14 = rotatedValue65.x;
				float clampResult4_g14 = clamp( (temp_output_23_0_g14 + (_BarMinPoint1 - 0.0) * (temp_output_27_0_g14 - temp_output_23_0_g14) / (1.0 - 0.0)) , temp_output_23_0_g14 , temp_output_9_0_g14 );
				float4 appendResult238 = (float4((( tex2DNode243 * IN.color )).rgb , ( IN.color.a * max( ( sign( ( temp_output_9_0_g14 - temp_output_21_0_g14 ) ) * sign( ( temp_output_21_0_g14 - clampResult4_g14 ) ) ) , 0.0 ) * tex2DNode243.a )));
				float2 uv_BarTexture2 = IN.texcoord.xy * _BarTexture2_ST.xy + _BarTexture2_ST.zw;
				float temp_output_23_0_g15 = _LeftOffset;
				float temp_output_27_0_g15 = ( _RightOffset + 1.0 );
				float temp_output_9_0_g15 = (temp_output_23_0_g15 + (_BarMaxPoint2 - 0.0) * (temp_output_27_0_g15 - temp_output_23_0_g15) / (1.0 - 0.0));
				float temp_output_21_0_g15 = rotatedValue65.x;
				float clampResult4_g15 = clamp( (temp_output_23_0_g15 + (_BarMinPoint2 - 0.0) * (temp_output_27_0_g15 - temp_output_23_0_g15) / (1.0 - 0.0)) , temp_output_23_0_g15 , temp_output_9_0_g15 );
				float temp_output_227_0 = ( _BarColor2.a * max( ( sign( ( temp_output_9_0_g15 - temp_output_21_0_g15 ) ) * sign( ( temp_output_21_0_g15 - clampResult4_g15 ) ) ) , 0.0 ) * IN.color.a );
				float4 appendResult228 = (float4((( tex2D( _BarTexture2, uv_BarTexture2 ) * _BarColor2 )).rgb , temp_output_227_0));
				float2 uv_BarTexture3 = IN.texcoord.xy * _BarTexture3_ST.xy + _BarTexture3_ST.zw;
				float temp_output_23_0_g16 = _LeftOffset;
				float temp_output_27_0_g16 = ( _RightOffset + 1.0 );
				float temp_output_9_0_g16 = (temp_output_23_0_g16 + (_BarMaxPoint3 - 0.0) * (temp_output_27_0_g16 - temp_output_23_0_g16) / (1.0 - 0.0));
				float temp_output_21_0_g16 = rotatedValue65.x;
				float clampResult4_g16 = clamp( (temp_output_23_0_g16 + (_BarMinPoint3 - 0.0) * (temp_output_27_0_g16 - temp_output_23_0_g16) / (1.0 - 0.0)) , temp_output_23_0_g16 , temp_output_9_0_g16 );
				float temp_output_224_0 = ( _BarColor3.a * max( ( sign( ( temp_output_9_0_g16 - temp_output_21_0_g16 ) ) * sign( ( temp_output_21_0_g16 - clampResult4_g16 ) ) ) , 0.0 ) * IN.color.a );
				float4 appendResult225 = (float4((( tex2D( _BarTexture3, uv_BarTexture3 ) * _BarColor3 )).rgb , temp_output_224_0));
				float4 lerpResult290 = lerp( appendResult228 , appendResult225 , temp_output_224_0);
				float4 lerpResult296 = lerp( appendResult225 , appendResult228 , temp_output_227_0);
				#if defined(_DRAWORDER_2OVER3)
				float4 staticSwitch300 = lerpResult296;
				#elif defined(_DRAWORDER_3OVER2)
				float4 staticSwitch300 = lerpResult290;
				#else
				float4 staticSwitch300 = lerpResult290;
				#endif
				float4 lerpResult298 = lerp( appendResult238 , staticSwitch300 , (staticSwitch300).w);
				
				fixed4 c = lerpResult298;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "FillBarShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
135;-1256;1781;908;2970.83;2445.986;2.180559;True;False
Node;AmplifyShaderEditor.RangedFloatNode;62;-3575.985,-1422.306;Inherit;False;Property;_EdgeAngle;Edge Angle;1;0;Create;True;0;0;0;False;0;False;0;-45;-90;90;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;103;-3588.996,-1279.392;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-3586.735,-1152.265;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;64;-3304.337,-1422.552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;104;-3341.995,-1237.392;Inherit;False;Property;_ImageType;ImageType;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Simple;Sliced;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;65;-3121.952,-1411.538;Inherit;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0.5,0.5,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-2833.984,-1569.399;Inherit;False;Property;_LeftOffset;Left Offset;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-2841.21,-1491.701;Inherit;False;Property;_RightOffset;Right Offset;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;253;-2453.211,-1027.135;Inherit;False;1790.578;754.64;;10;218;219;226;220;221;222;223;225;224;244;Bar 3;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;252;-2459.001,-1870.58;Inherit;False;1792.804;752.7762;;10;213;214;229;230;233;231;232;228;227;249;Bar 2;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-2406.282,-1743.597;Inherit;False;Property;_BarMaxPoint2;Bar Max Point 2;10;0;Create;True;0;0;0;False;0;False;0.6;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-2403.211,-977.1351;Inherit;False;Property;_BarMinPoint3;Bar Min Point 3;13;0;Create;True;0;0;0;False;0;False;0.4;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-2400.492,-900.1554;Inherit;False;Property;_BarMaxPoint3;Bar Max Point 3;14;0;Create;True;0;0;0;False;0;False;0.6;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-2409.001,-1820.58;Inherit;False;Property;_BarMinPoint2;Bar Min Point 2;9;0;Create;True;0;0;0;False;0;False;0.5;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;-2813.429,-1411.37;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;257;-2630.992,-807.1318;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;256;-2573.506,-829.0472;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;286;-2045.578,-724.6395;Inherit;False;GetUVRegion;-1;;16;9612b7e748f24482dab7cbf2d1ea4c65;0;5;19;FLOAT;0;False;20;FLOAT;0;False;23;FLOAT;0;False;24;FLOAT;0;False;21;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;221;-1536.324,-684.4391;Inherit;False;Property;_BarColor3;Bar Color 3;12;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;220;-1624.324,-874.439;Inherit;True;Property;_BarTexture3;Bar Texture 3;11;0;Create;True;0;0;0;False;0;False;-1;64e7766099ad46747a07014e44d0aea1;64e7766099ad46747a07014e44d0aea1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;285;-2051.369,-1568.082;Inherit;False;GetUVRegion;-1;;15;9612b7e748f24482dab7cbf2d1ea4c65;0;5;19;FLOAT;0;False;20;FLOAT;0;False;23;FLOAT;0;False;24;FLOAT;0;False;21;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;229;-1540.572,-1524.601;Inherit;False;Property;_BarColor2;Bar Color 2;8;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;230;-1628.572,-1717.601;Inherit;True;Property;_BarTexture2;Bar Texture 2;7;0;Create;True;0;0;0;False;0;False;-1;6b2910686f14f5844bf4707db2d5e2ba;6b2910686f14f5844bf4707db2d5e2ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;226;-1671.188,-542.741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-1285.324,-703.4391;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;244;-1491.542,-479.4952;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;245;-2460.614,-2536.344;Inherit;False;1795.456;576.4172;;10;186;189;236;237;239;238;243;242;241;240;Bar 1;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;233;-1678.555,-1381.588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;249;-1496.105,-1324.804;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-1290.28,-1543.807;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;223;-1127.324,-708.4392;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-2410.614,-2486.344;Inherit;False;Property;_BarMinPoint1;Bar Min Point 1;5;0;Create;True;0;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;258;-2554.766,-2040.871;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;232;-1133.441,-1549.067;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-1070.5,-1425.01;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-1066.928,-583.0072;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-2407.895,-2409.364;Inherit;False;Property;_BarMaxPoint1;Bar Max Point 1;6;0;Create;True;0;0;0;False;0;False;0.5;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;242;-1811.559,-2378.137;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;255;-2598.312,-2056.993;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;225;-916.634,-703.0072;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;284;-2052.981,-2233.848;Inherit;False;GetUVRegion;-1;;14;9612b7e748f24482dab7cbf2d1ea4c65;0;5;19;FLOAT;0;False;20;FLOAT;0;False;23;FLOAT;0;False;24;FLOAT;0;False;21;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;243;-1625.942,-2383.69;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;241;-1497.332,-2190.739;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;228;-920.1979,-1543.692;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-1287.848,-2215.364;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;296;-313.5132,-1568.161;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;290;-316.3012,-727.0106;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;240;-1678.893,-2050.563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-1069.452,-2094.927;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;300;19.14806,-1136.24;Inherit;False;Property;_DrawOrder;Draw Order;4;0;Create;True;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;2over3;3over2;Create;True;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;237;-1129.848,-2220.364;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;238;-919.1581,-2214.932;Inherit;True;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;297;262.7882,-1019.663;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;298;518.5569,-1154.265;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;696.6234,-1153.987;Float;False;True;-1;2;FillBarShaderEditor;0;8;mrvc/FillBarShader;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;64;0;62;0
WireConnection;104;1;103;0
WireConnection;104;0;102;0
WireConnection;65;1;64;0
WireConnection;65;3;104;0
WireConnection;67;0;65;0
WireConnection;257;0;110;0
WireConnection;256;0;109;0
WireConnection;286;19;219;0
WireConnection;286;20;218;0
WireConnection;286;23;256;0
WireConnection;286;24;257;0
WireConnection;286;21;67;0
WireConnection;285;19;214;0
WireConnection;285;20;213;0
WireConnection;285;23;109;0
WireConnection;285;24;110;0
WireConnection;285;21;67;0
WireConnection;226;0;286;0
WireConnection;222;0;220;0
WireConnection;222;1;221;0
WireConnection;233;0;285;0
WireConnection;231;0;230;0
WireConnection;231;1;229;0
WireConnection;223;0;222;0
WireConnection;258;0;110;0
WireConnection;232;0;231;0
WireConnection;227;0;229;4
WireConnection;227;1;233;0
WireConnection;227;2;249;4
WireConnection;224;0;221;4
WireConnection;224;1;226;0
WireConnection;224;2;244;4
WireConnection;255;0;109;0
WireConnection;225;0;223;0
WireConnection;225;3;224;0
WireConnection;284;19;189;0
WireConnection;284;20;186;0
WireConnection;284;23;255;0
WireConnection;284;24;258;0
WireConnection;284;21;67;0
WireConnection;243;0;242;0
WireConnection;228;0;232;0
WireConnection;228;3;227;0
WireConnection;236;0;243;0
WireConnection;236;1;241;0
WireConnection;296;0;225;0
WireConnection;296;1;228;0
WireConnection;296;2;227;0
WireConnection;290;0;228;0
WireConnection;290;1;225;0
WireConnection;290;2;224;0
WireConnection;240;0;284;0
WireConnection;239;0;241;4
WireConnection;239;1;240;0
WireConnection;239;2;243;4
WireConnection;300;1;296;0
WireConnection;300;0;290;0
WireConnection;237;0;236;0
WireConnection;238;0;237;0
WireConnection;238;3;239;0
WireConnection;297;0;300;0
WireConnection;298;0;238;0
WireConnection;298;1;300;0
WireConnection;298;2;297;0
WireConnection;0;0;298;0
ASEEND*/
//CHKSM=DE70DAE21BED701954DF643699485458FE21A6CB