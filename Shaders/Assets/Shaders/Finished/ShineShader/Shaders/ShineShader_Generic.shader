// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/GenericShine"
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
		_ShineLocation("Shine Location", Range( 0 , 1)) = 0.5
		_ShineWidth("Shine Width", Range( 0 , 1)) = 0.05
		_ShineGlow("Shine Glow", Range( 0 , 15)) = 1
		[KeywordEnum(Simple,Sliced)] _ImageType("ImageType", Float) = 0
		_RotateAngle("Rotate Angle", Float) = 0
		_ShineColor("Shine Color", Color) = (1,1,1,1)
		_ShineMask("Shine Mask", 2D) = "white" {}
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
			uniform float4 _MainTex_ST;
			uniform float4 _ShineColor;
			uniform float _ShineLocation;
			uniform float _ShineWidth;
			uniform float _RotateAngle;
			uniform float _ShineGlow;
			uniform sampler2D _ShineMask;
			uniform float4 _ShineMask_ST;
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
				float4 tex2DNode84 = tex2D( _MainTex, uv_MainTex );
				float temp_output_162_0 = (-0.1 + (_ShineLocation - 0.0) * (0.6 - -0.1) / (1.0 - 0.0));
				float2 texCoord155 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord157 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch156 = texCoord155;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch156 = texCoord157;
				#else
				float2 staticSwitch156 = texCoord155;
				#endif
				float3 rotatedValue80 = RotateAroundAxis( float3( 0.5,0.5,0.5 ), float3( staticSwitch156 ,  0.0 ), float3( 0,0,1 ), radians( _RotateAngle ) );
				float temp_output_89_0 = ( rotatedValue80.x * 0.5 );
				float2 uv_ShineMask = IN.texcoord.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				float2 uv4_ShineMask = IN.ase_texcoord2.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch161 = uv_ShineMask;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch161 = uv4_ShineMask;
				#else
				float2 staticSwitch161 = uv_ShineMask;
				#endif
				float temp_output_137_0 = (( max( sign( ( ( temp_output_162_0 + _ShineWidth ) - temp_output_89_0 ) ) , 0.0 ) * max( sign( ( temp_output_89_0 - ( temp_output_162_0 - _ShineWidth ) ) ) , 0.0 ) * ( ( 1.0 - ( abs( ( temp_output_89_0 - temp_output_162_0 ) ) / _ShineWidth ) ) * _ShineGlow * tex2DNode84.a ) * tex2D( _ShineMask, staticSwitch161 ) )).a;
				float4 appendResult151 = (float4(_ShineColor.rgb , temp_output_137_0));
				float smoothstepResult154 = smoothstep( 0.0 , 1.0 , temp_output_137_0);
				float4 lerpResult136 = lerp( ( tex2DNode84 * IN.color ) , appendResult151 , smoothstepResult154);
				float4 appendResult153 = (float4(lerpResult136.xyz , tex2DNode84.a));
				
				half4 color = appendResult153;
				
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
	CustomEditor "GenericShineShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
-184;-1324;1792;1001;1330.889;695.6752;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;157;-1586.123,110.832;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-1587.384,-16.29504;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-1434.723,-107.2637;Inherit;False;Property;_RotateAngle;Rotate Angle;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;156;-1341.384,25.70496;Inherit;False;Property;_ImageType;ImageType;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Simple;Sliced;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RadiansOpNode;133;-1269.074,-104.5093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;80;-1097.599,-119.6775;Inherit;False;False;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT3;0.5,0.5,0.5;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-984.8572,-529.1839;Inherit;False;Property;_ShineLocation;Shine Location;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;130;-762.0737,-172.5093;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-622.835,-172.4891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;162;-692.8887,-524.6752;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.1;False;4;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-427.1784,-26.43953;Inherit;False;Property;_ShineWidth;Shine Width;1;0;Create;True;0;0;0;False;0;False;0.05;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-437.2474,-140.5554;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;122;-488.2532,-290.7911;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-484.5629,-265.8375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-122.2532,-444.7911;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-127.2007,-238.0006;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;93;-285.2512,-137.9792;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;112;28.98047,-305.9401;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;94;-129.391,-99.33604;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;83;-311.8349,176.1334;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;121;27.74683,-407.7911;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;158;-325.353,-594.0837;Inherit;False;3;78;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;159;-327.353,-725.0837;Inherit;False;0;78;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SignOpNode;123;157.7468,-404.7911;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;1.995503,-96.75987;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;116;159.0402,-303.4432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;-137.941,173.8453;Inherit;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;161;-78.14427,-675.114;Inherit;False;Property;_Keyword0;Keyword 0;3;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;156;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-115.811,5.472351;Inherit;False;Property;_ShineGlow;Shine Glow;2;0;Create;True;0;0;0;False;0;False;1;0;0;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;118;289.5597,-439.6287;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;103;292.3492,-261.1045;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;201.2492,-79.20447;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;78;110.1535,-698.4735;Inherit;True;Property;_ShineMask;Shine Mask;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;512.8176,-279.6428;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;129;680.6302,-156.6938;Inherit;False;Property;_ShineColor;Shine Color;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;144;-10.37461,368.3129;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;137;689.5433,-247.6477;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;151;893.0062,-151.6764;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SmoothstepOpNode;154;1053.684,-301.6786;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;220.7205,177.0175;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;136;1205.932,-104.3029;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;1382.2,113.893;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;49;1532.996,114.5783;Float;False;True;-1;2;GenericShineShaderEditor;0;6;mrvc/GenericShine;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;156;1;155;0
WireConnection;156;0;157;0
WireConnection;133;0;75;0
WireConnection;80;1;133;0
WireConnection;80;3;156;0
WireConnection;130;0;80;0
WireConnection;89;0;130;0
WireConnection;162;0;74;0
WireConnection;91;0;89;0
WireConnection;91;1;162;0
WireConnection;122;0;89;0
WireConnection;117;0;89;0
WireConnection;119;0;162;0
WireConnection;119;1;76;0
WireConnection;113;0;162;0
WireConnection;113;1;76;0
WireConnection;93;0;91;0
WireConnection;112;0;117;0
WireConnection;112;1;113;0
WireConnection;94;0;93;0
WireConnection;94;1;76;0
WireConnection;121;0;119;0
WireConnection;121;1;122;0
WireConnection;123;0;121;0
WireConnection;95;0;94;0
WireConnection;116;0;112;0
WireConnection;84;0;83;0
WireConnection;161;1;159;0
WireConnection;161;0;158;0
WireConnection;118;0;123;0
WireConnection;103;0;116;0
WireConnection;102;0;95;0
WireConnection;102;1;77;0
WireConnection;102;2;84;4
WireConnection;78;1;161;0
WireConnection;125;0;118;0
WireConnection;125;1;103;0
WireConnection;125;2;102;0
WireConnection;125;3;78;0
WireConnection;137;0;125;0
WireConnection;151;0;129;0
WireConnection;151;3;137;0
WireConnection;154;0;137;0
WireConnection;145;0;84;0
WireConnection;145;1;144;0
WireConnection;136;0;145;0
WireConnection;136;1;151;0
WireConnection;136;2;154;0
WireConnection;153;0;136;0
WireConnection;153;3;84;4
WireConnection;49;0;153;0
ASEEND*/
//CHKSM=9A5F42A65CB3D8256F9D0456DFF7BD16A32A469E