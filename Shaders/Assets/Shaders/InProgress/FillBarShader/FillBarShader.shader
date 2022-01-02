// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FillBarShader"
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
		_MainBarFill("Main Bar Fill", Range( 0 , 1)) = 0.5
		_IncreaseFill("Increase Fill", Range( 0 , 1)) = 0.5
		_IncreaseFillTexture("Increase Fill Texture", 2D) = "white" {}
		_IncreaseFillColor("Increase Fill Color", Color) = (1,1,1,1)
		_DecreaseFill("Decrease Fill", Range( 0 , 1)) = 0.2
		_DecreaseFillTexture("Decrease Fill Texture", 2D) = "white" {}
		_DecreaseFillColor("Decrease Fill Color", Color) = (1,1,1,1)
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
			uniform sampler2D _IncreaseFillTexture;
			uniform float4 _IncreaseFillTexture_ST;
			uniform float4 _IncreaseFillColor;
			uniform float _IncreaseFill;
			uniform float _LeftOffset;
			uniform float _RightOffset;
			uniform float _EdgeAngle;
			uniform float _MainBarFill;
			uniform float4 _MainTex_ST;
			uniform sampler2D _DecreaseFillTexture;
			uniform float4 _DecreaseFillTexture_ST;
			uniform float4 _DecreaseFillColor;
			uniform float _DecreaseFill;
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

				float2 uv_IncreaseFillTexture = IN.texcoord.xy * _IncreaseFillTexture_ST.xy + _IncreaseFillTexture_ST.zw;
				float temp_output_111_0 = ( _RightOffset + 1.0 );
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
				float temp_output_87_0 = max( sign( ( (_LeftOffset + (_MainBarFill - 0.0) * (temp_output_111_0 - _LeftOffset) / (1.0 - 0.0)) - rotatedValue65.x ) ) , 0.0 );
				float temp_output_95_0 = ( 1.0 - temp_output_87_0 );
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode7 = tex2D( _MainTex, uv_MainTex );
				float4 temp_output_97_0 = ( tex2DNode7 * IN.color );
				float temp_output_122_0 = (temp_output_97_0).a;
				float4 appendResult119 = (float4((( tex2D( _IncreaseFillTexture, uv_IncreaseFillTexture ) * _IncreaseFillColor )).rgb , ( _IncreaseFillColor.a * ( max( sign( ( (_LeftOffset + (_IncreaseFill - 0.0) * (temp_output_111_0 - _LeftOffset) / (1.0 - 0.0)) - rotatedValue65.x ) ) , 0.0 ) * temp_output_95_0 ) * temp_output_122_0 )));
				float smoothstepResult31 = smoothstep( temp_output_95_0 , 1.0 , tex2DNode7.a);
				float temp_output_98_0 = ( IN.color.a * smoothstepResult31 );
				float4 appendResult27 = (float4((temp_output_97_0).rgb , temp_output_98_0));
				float4 lerpResult117 = lerp( appendResult119 , appendResult27 , temp_output_98_0);
				float2 uv_DecreaseFillTexture = IN.texcoord.xy * _DecreaseFillTexture_ST.xy + _DecreaseFillTexture_ST.zw;
				float temp_output_150_0 = ( _DecreaseFillColor.a * max( ( temp_output_87_0 - max( sign( ( (_LeftOffset + (_DecreaseFill - 0.0) * (temp_output_111_0 - _LeftOffset) / (1.0 - 0.0)) - rotatedValue65.x ) ) , 0.0 ) ) , 0.0 ) * temp_output_122_0 );
				float4 appendResult151 = (float4((( tex2D( _DecreaseFillTexture, uv_DecreaseFillTexture ) * _DecreaseFillColor )).rgb , temp_output_150_0));
				float4 lerpResult170 = lerp( lerpResult117 , appendResult151 , temp_output_150_0);
				
				fixed4 c = lerpResult170;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
0;25;1781;908;2668.195;1689.914;1.765033;True;False
Node;AmplifyShaderEditor.RangedFloatNode;62;-2360.208,-864.0879;Inherit;False;Property;_EdgeAngle;Edge Angle;1;0;Create;True;0;0;0;False;0;False;0;-45;-90;90;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;103;-2373.219,-721.1705;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-2370.958,-594.0432;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RadiansOpNode;64;-2088.56,-864.3334;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;104;-2126.218,-679.1703;Inherit;False;Property;_ImageType;ImageType;0;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Simple;Sliced;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1850.011,-522.1619;Inherit;False;Property;_RightOffset;Right Offset;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1321.416,-542.4229;Inherit;False;Property;_MainBarFill;Main Bar Fill;4;0;Create;True;0;0;0;False;0;False;0.5;0.505;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;65;-1906.175,-853.3191;Inherit;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0.5,0.5,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-1846.738,-601.8015;Inherit;False;Property;_LeftOffset;Left Offset;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1695.096,-514.525;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;-1597.651,-853.1509;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TFHCRemapNode;108;-1016.449,-505.7585;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-1209.71,-1206.094;Inherit;False;Property;_IncreaseFill;Increase Fill;5;0;Create;True;0;0;0;False;0;False;0.5;0.505;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-1268.005,-1678.775;Inherit;False;Property;_DecreaseFill;Decrease Fill;8;0;Create;True;0;0;0;False;0;False;0.2;0.505;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-813.0993,-322.4821;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;137;-931.0544,-1159.679;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;153;-959.0059,-1627.775;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;85;-672,-320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;125;-732.5693,-1021.83;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;28;-163.2542,-790.7295;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SignOpNode;126;-588.5693,-1021.83;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;154;-760.5209,-1489.926;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;87;-549.9616,-320.2898;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;155;-616.5209,-1489.926;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;144;-460.8519,-1021.247;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;45.47095,-796.6865;Inherit;True;Property;_TextureSample0;Texture Sample 0;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;95;-409.5982,-320.6501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;96;173.4711,-588.6865;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-272.9175,-1039.317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;413.471,-748.6865;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;123;164.0567,-1065.481;Inherit;False;Property;_IncreaseFillColor;Increase Fill Color;7;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;156;-478.2069,-1443.819;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;114;76.05676,-1258.481;Inherit;True;Property;_IncreaseFillTexture;Increase Fill Texture;6;0;Create;True;0;0;0;False;0;False;-1;6b2910686f14f5844bf4707db2d5e2ba;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;429.4711,-1084.687;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;146;75.31885,-1653.795;Inherit;True;Property;_DecreaseFillTexture;Decrease Fill Texture;9;0;Create;True;0;0;0;False;0;False;-1;64e7766099ad46747a07014e44d0aea1;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;122;605.4712,-796.6865;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;509.4711,-348.6865;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;169;-303.9701,-1368.384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;183;86.26041,-894.2081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;147;163.3188,-1463.795;Inherit;False;Property;_DecreaseFillColor;Decrease Fill Color;10;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;848.3436,-940.6865;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;414.3188,-1482.795;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;118;606.4712,-1088.687;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;733.4713,-412.6865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;26;605.4712,-668.6865;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;173;-65.38956,-1332.533;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;149;572.3188,-1487.795;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;818.4183,-1357.495;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;893.4713,-540.6865;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;119;992.3437,-1036.687;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;117;1185.085,-572.6865;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;151;962.4185,-1453.495;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;170;1500.761,-1004.082;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2066.045,-676.1473;Float;False;True;-1;2;ASEMaterialInspector;0;8;FillBarShader;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;64;0;62;0
WireConnection;104;1;103;0
WireConnection;104;0;102;0
WireConnection;65;1;64;0
WireConnection;65;3;104;0
WireConnection;111;0;110;0
WireConnection;67;0;65;0
WireConnection;108;0;66;0
WireConnection;108;3;109;0
WireConnection;108;4;111;0
WireConnection;77;0;108;0
WireConnection;77;1;67;0
WireConnection;137;0;135;0
WireConnection;137;3;109;0
WireConnection;137;4;111;0
WireConnection;153;0;152;0
WireConnection;153;3;109;0
WireConnection;153;4;111;0
WireConnection;85;0;77;0
WireConnection;125;0;137;0
WireConnection;125;1;67;0
WireConnection;126;0;125;0
WireConnection;154;0;153;0
WireConnection;154;1;67;0
WireConnection;87;0;85;0
WireConnection;155;0;154;0
WireConnection;144;0;126;0
WireConnection;7;0;28;0
WireConnection;95;0;87;0
WireConnection;139;0;144;0
WireConnection;139;1;95;0
WireConnection;97;0;7;0
WireConnection;97;1;96;0
WireConnection;156;0;155;0
WireConnection;113;0;114;0
WireConnection;113;1;123;0
WireConnection;122;0;97;0
WireConnection;31;0;7;4
WireConnection;31;1;95;0
WireConnection;169;0;87;0
WireConnection;169;1;156;0
WireConnection;183;0;139;0
WireConnection;124;0;123;4
WireConnection;124;1;183;0
WireConnection;124;2;122;0
WireConnection;148;0;146;0
WireConnection;148;1;147;0
WireConnection;118;0;113;0
WireConnection;98;0;96;4
WireConnection;98;1;31;0
WireConnection;26;0;97;0
WireConnection;173;0;169;0
WireConnection;149;0;148;0
WireConnection;150;0;147;4
WireConnection;150;1;173;0
WireConnection;150;2;122;0
WireConnection;27;0;26;0
WireConnection;27;3;98;0
WireConnection;119;0;118;0
WireConnection;119;3;124;0
WireConnection;117;0;119;0
WireConnection;117;1;27;0
WireConnection;117;2;98;0
WireConnection;151;0;149;0
WireConnection;151;3;150;0
WireConnection;170;0;117;0
WireConnection;170;1;151;0
WireConnection;170;2;150;0
WireConnection;0;0;170;0
ASEEND*/
//CHKSM=E495D718BAEC8555AF0A8299078B2DB6225E9823