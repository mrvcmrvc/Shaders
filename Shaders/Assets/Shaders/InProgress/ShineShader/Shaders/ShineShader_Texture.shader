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
		_ShineTexture("ShineTexture", 2D) = "white" {}
		_XMovement("XMovement", Range( 0 , 1)) = 0.5
		[KeywordEnum(Simple,Sliced)] _ImageType("ImageType", Float) = 0
		_ShineLocation("Shine Location", Range( 0 , 1)) = 0.5
		_ShineColor("ShineColor", Color) = (1,1,1,1)
		_YMovement("YMovement", Range( 0 , 1)) = 0
		_ShineMask("ShineMask", 2D) = "white" {}
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
			uniform sampler2D _ShineTexture;
			uniform float4 _ShineTexture_ST;
			uniform float _ShineLocation;
			uniform float _XMovement;
			uniform float _YMovement;
			uniform sampler2D _ShineMask;
			uniform float4 _ShineMask_ST;

			
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
				float4 temp_output_180_0 = ( IN.color * tex2DNode28 );
				float2 lerpResult196 = lerp( float2( 1,1 ) , ( _ShineTexture_ST.xy * float2( -1,-1 ) ) , _ShineLocation);
				float2 appendResult195 = (float2(_XMovement , _YMovement));
				float2 lerpResult191 = lerp( ( ( 1.0 - _ShineTexture_ST.xy ) * float2( 0.5,0.5 ) ) , lerpResult196 , appendResult195);
				float2 temp_output_193_0 = ( _ShineTexture_ST.zw + lerpResult191 );
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
				float2 uv_ShineMask = IN.texcoord.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				float2 uv4_ShineMask = IN.ase_texcoord2.xy * _ShineMask_ST.xy + _ShineMask_ST.zw;
				#if defined(_IMAGETYPE_SIMPLE)
				float2 staticSwitch199 = uv_ShineMask;
				#elif defined(_IMAGETYPE_SLICED)
				float2 staticSwitch199 = uv4_ShineMask;
				#else
				float2 staticSwitch199 = uv_ShineMask;
				#endif
				float4 lerpResult157 = lerp( temp_output_180_0 , ( _ShineColor * tex2DNode91 ) , ( tex2DNode28.a * ( _ShineColor.a * tex2DNode91.a * tex2D( _ShineMask, staticSwitch199 ).a ) ));
				float4 appendResult177 = (float4(lerpResult157.rgb , (temp_output_180_0).a));
				
				half4 color = appendResult177;
				
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
218;-1228;1792;1001;18.30818;-419.2253;1;True;True
Node;AmplifyShaderEditor.TextureTransformNode;190;-540.5094,1280.453;Inherit;False;91;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;186;-409.7574,1696.049;Inherit;False;Property;_YMovement;YMovement;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-409.2574,1617.049;Inherit;False;Property;_XMovement;XMovement;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-460.3445,1480.183;Inherit;False;Property;_ShineLocation;Shine Location;3;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;188;-325.3584,1211.048;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-326.2584,1378.05;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;196;-172.1525,1436.433;Inherit;False;3;0;FLOAT2;1,1;False;1;FLOAT2;-1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-161.3605,1212.048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;195;-132.2615,1651.049;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;191;32.73737,1428.05;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;192;32.73737,1325.05;Inherit;False;91;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;193;236.7369,1440.05;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;551.1777,1439.415;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;548.917,1312.288;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;535.1754,1795.165;Inherit;False;3;198;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;201;533.1754,1664.165;Inherit;False;0;198;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;146;795.917,1354.288;Inherit;False;Property;_ImageType;ImageType;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Simple;Sliced;Create;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;199;800.1754,1699.165;Inherit;False;Property;_Keyword0;Keyword 0;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;146;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;91;1020.764,1330.805;Inherit;True;Property;_ShineTexture;ShineTexture;0;0;Create;True;0;0;0;False;0;False;-1;None;e2317eb2d2d9d481b9ada5dd424268ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;116;851.016,831.541;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;182;1102.363,1156.097;Inherit;False;Property;_ShineColor;ShineColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;198;1024.175,1667.165;Inherit;True;Property;_ShineMask;ShineMask;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;179;1132.201,662.2229;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;1010.546,829.2253;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;6dc9c112f83364b87a64dc2c46c4c6d1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;1378.475,1066.544;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1394.644,1253.638;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;1332.271,758.3494;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;1503.422,996.7402;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;1899.766,914.9109;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;181;1859.201,820.4081;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;177;2131.316,876.7684;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;115;2270.855,877.9699;Float;False;True;-1;2;TexturedShineShaderEditor;0;6;mrvc/TexturedShine;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;188;0;190;0
WireConnection;185;0;190;0
WireConnection;196;1;185;0
WireConnection;196;2;187;0
WireConnection;194;0;188;0
WireConnection;195;0;189;0
WireConnection;195;1;186;0
WireConnection;191;0;194;0
WireConnection;191;1;196;0
WireConnection;191;2;195;0
WireConnection;193;0;192;1
WireConnection;193;1;191;0
WireConnection;124;0;192;0
WireConnection;124;1;193;0
WireConnection;147;0;192;0
WireConnection;147;1;193;0
WireConnection;146;1;147;0
WireConnection;146;0;124;0
WireConnection;199;1;201;0
WireConnection;199;0;200;0
WireConnection;91;1;146;0
WireConnection;198;1;199;0
WireConnection;28;0;116;0
WireConnection;184;0;182;4
WireConnection;184;1;91;4
WireConnection;184;2;198;4
WireConnection;183;0;182;0
WireConnection;183;1;91;0
WireConnection;180;0;179;0
WireConnection;180;1;28;0
WireConnection;171;0;28;4
WireConnection;171;1;184;0
WireConnection;157;0;180;0
WireConnection;157;1;183;0
WireConnection;157;2;171;0
WireConnection;181;0;180;0
WireConnection;177;0;157;0
WireConnection;177;3;181;0
WireConnection;115;0;177;0
ASEEND*/
//CHKSM=49604E03041A1CC2BE7B3109033C45605155ABB4