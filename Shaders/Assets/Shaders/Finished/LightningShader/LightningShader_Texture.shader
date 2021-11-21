// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/TexturedLightningShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_NoiseStrength("Noise Strength", Range( 0 , 1)) = 0
		_Speed("Speed", Vector) = (0.8,0.5,0,0)
		[HDR]_LightningColor("Lightning Color", Color) = (0.6469544,1.226316,1.231144,1)
		_NoiseOffset("Noise Offset", Float) = 0
		_EdgeConstraintScale("Edge Constraint Scale", Range( 0 , 1)) = 0
		_EdgeInnerOffset("Edge Inner Offset", Range( -10 , 0)) = 0
		_EdgeOuterOffset("Edge Outer Offset", Range( 1 , 10)) = 1
		_RadialScale("Radial Scale", Range( 0 , 1)) = 1
		_RadialScaleCenter("Radial Scale Center", Vector) = (0.5,0.5,0,0)
		_RadialOffsetStrength("Radial Offset Strength", Range( -1 , 1)) = 0
		[HideInInspector]_CurTime("CurTime", Float) = 0
		_LightningTexture("LightningTexture", 2D) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
		
		
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
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _LightningTexture;
			uniform float4 _LightningTexture_ST;
			uniform float2 _RadialScaleCenter;
			uniform float _RadialScale;
			uniform float _RadialOffsetStrength;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float _CurTime;
			uniform float2 _Speed;
			uniform float _NoiseOffset;
			uniform float _NoiseStrength;
			uniform float _EdgeConstraintScale;
			uniform float _EdgeInnerOffset;
			uniform float _EdgeOuterOffset;
			uniform float4 _LightningColor;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
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

				float2 CenteredUV15_g3 = ( IN.texcoord.xy - _RadialScaleCenter );
				float2 break17_g3 = CenteredUV15_g3;
				float2 appendResult23_g3 = (float2(( length( CenteredUV15_g3 ) * _RadialScale * 2.0 ) , ( atan2( break17_g3.x , break17_g3.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 appendResult143 = (float2(( ( 1.0 - (appendResult23_g3).x ) * _RadialOffsetStrength ) , 0.0));
				float2 texCoord63 = IN.texcoord.xy * _LightningTexture_ST.xy + appendResult143;
				float2 panner43 = ( _CurTime * _Speed + float2( 0,0 ));
				float2 texCoord51 = IN.texcoord.xy * _Noise_ST.xy + panner43;
				float clampResult130 = clamp( tex2D( _Noise, ( texCoord51 + _NoiseOffset ) ).r , 0.0 , 1.0 );
				float2 temp_cast_0 = (clampResult130).xx;
				float2 lerpResult53 = lerp( texCoord63 , temp_cast_0 , _NoiseStrength);
				float2 CenteredUV15_g4 = ( IN.texcoord.xy - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * _EdgeConstraintScale * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float clampResult132 = clamp( (_EdgeInnerOffset + (( 1.0 - (appendResult23_g4).x ) - 0.0) * (_EdgeOuterOffset - _EdgeInnerOffset) / (1.0 - 0.0)) , 0.0 , 1.0 );
				float2 lerpResult127 = lerp( texCoord63 , lerpResult53 , clampResult132);
				
				fixed4 c = ( tex2D( _LightningTexture, lerpResult127 ) * _LightningColor );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "TexturedLightningShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
0;25;1792;1001;2597.003;880.3301;1;True;False
Node;AmplifyShaderEditor.Vector2Node;140;-2763.11,-763.2639;Inherit;False;Property;_RadialScaleCenter;Radial Scale Center;9;0;Create;True;0;0;0;False;0;False;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;139;-2830.51,-636.2643;Inherit;False;Property;_RadialScale;Radial Scale;8;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;116;-2464.799,-429.8712;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;0.8,0.5;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;158;-2443.676,-303.3677;Inherit;False;Property;_CurTime;CurTime;11;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;141;-2458.758,-707.9318;Inherit;False;Polar Coordinates;-1;;3;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;142;-2236.358,-712.3318;Inherit;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-2282.934,-68.08761;Inherit;False;Property;_EdgeConstraintScale;Edge Constraint Scale;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;43;-2277.754,-385.8563;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;159;-2301.807,-529.4236;Inherit;False;129;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-2089.973,-502.8572;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;144;-2038.099,-706.9507;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2159.07,-625.6041;Inherit;False;Property;_RadialOffsetStrength;Radial Offset Strength;10;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;124;-1975.106,-111.8744;Inherit;False;Polar Coordinates;-1;;4;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-2041.037,-386.485;Inherit;False;Property;_NoiseOffset;Noise Offset;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;125;-1753.88,-115.7331;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-1869.072,-666.9038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1852.037,-405.485;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;143;-1723.259,-599.2314;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;126;-1568.237,-109.588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1689.797,-38.54055;Inherit;False;Property;_EdgeInnerOffset;Edge Inner Offset;6;0;Create;True;0;0;0;False;0;False;0;0;-10;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1692.691,52.50993;Inherit;False;Property;_EdgeOuterOffset;Edge Outer Offset;7;0;Create;True;0;0;0;False;0;False;1;1.5;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;129;-1731.094,-434.6979;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;0;False;0;False;-1;None;b54dbeca5d71d4b06b7cab2f01de88b3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureTransformNode;162;-1730.003,-711.3301;Inherit;False;160;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.ClampOpNode;130;-1424.471,-432.0527;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;131;-1394.212,-107.2483;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1560.556,-240.392;Inherit;False;Property;_NoiseStrength;Noise Strength;1;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1510.612,-563.7334;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;53;-1250.008,-457.4677;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;132;-1220.212,-106.2483;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;-1005.873,-561.0125;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;160;-804.0032,-589.3301;Inherit;True;Property;_LightningTexture;LightningTexture;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;69;-718.6852,-373.5718;Inherit;False;Property;_LightningColor;Lightning Color;3;1;[HDR];Create;True;0;0;0;False;0;False;0.6469544,1.226316,1.231144,1;0.3362427,0.6892975,1.605559,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-479.61,-481.4575;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;29;-237.7497,-480.7224;Float;False;True;-1;2;TexturedLightningShaderEditor;0;8;mrvc/TexturedLightningShader;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;3;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;141;2;140;0
WireConnection;141;3;139;0
WireConnection;142;0;141;0
WireConnection;43;2;116;0
WireConnection;43;1;158;0
WireConnection;51;0;159;0
WireConnection;51;1;43;0
WireConnection;144;0;142;0
WireConnection;124;3;128;0
WireConnection;125;0;124;0
WireConnection;145;0;144;0
WireConnection;145;1;146;0
WireConnection;118;0;51;0
WireConnection;118;1;117;0
WireConnection;143;0;145;0
WireConnection;126;0;125;0
WireConnection;129;1;118;0
WireConnection;130;0;129;1
WireConnection;131;0;126;0
WireConnection;131;3;133;0
WireConnection;131;4;134;0
WireConnection;63;0;162;0
WireConnection;63;1;143;0
WireConnection;53;0;63;0
WireConnection;53;1;130;0
WireConnection;53;2;54;0
WireConnection;132;0;131;0
WireConnection;127;0;63;0
WireConnection;127;1;53;0
WireConnection;127;2;132;0
WireConnection;160;1;127;0
WireConnection;68;0;160;0
WireConnection;68;1;69;0
WireConnection;29;0;68;0
ASEEND*/
//CHKSM=CC82EE645EF889ADB241F257BF87763EF6669F25