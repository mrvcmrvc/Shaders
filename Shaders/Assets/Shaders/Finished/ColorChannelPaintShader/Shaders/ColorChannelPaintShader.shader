// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/ColorChannelPaintShader"
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
		_RColor("RColor", Color) = (1,1,1,1)
		_GColor("GColor", Color) = (1,1,1,1)
		_BColor("BColor", Color) = (1,1,1,1)
		_RGColor("RGColor", Color) = (1,1,1,1)
		_RBColor("RBColor", Color) = (1,1,1,1)
		_GBColor("GBColor", Color) = (1,1,1,1)
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
			uniform float4 _MainTex_ST;
			uniform float4 _RColor;
			uniform float4 _GColor;
			uniform float4 _BColor;
			uniform float4 _RGColor;
			uniform float4 _RBColor;
			uniform float4 _GBColor;

			
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

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode93 = tex2D( _MainTex, uv_MainTex );
				float4 tex2DNode95 = tex2D( _MainTex, uv_MainTex );
				float4 tex2DNode101 = tex2D( _MainTex, uv_MainTex );
				float4 tex2DNode106 = tex2D( _MainTex, uv_MainTex );
				float4 tex2DNode107 = tex2D( _MainTex, uv_MainTex );
				float4 tex2DNode108 = tex2D( _MainTex, uv_MainTex );
				float4 appendResult26 = (float4((( ( ( ( tex2DNode93.r - ( tex2DNode93.r * tex2DNode93.g ) ) - ( tex2DNode93.r * tex2DNode93.b ) ) * _RColor ) + ( ( ( tex2DNode95.g - ( tex2DNode95.r * tex2DNode95.g ) ) - ( tex2DNode95.g * tex2DNode95.b ) ) * _GColor ) + ( ( ( tex2DNode101.b - ( tex2DNode101.r * tex2DNode101.b ) ) - ( tex2DNode101.g * tex2DNode101.b ) ) * _BColor ) + ( ( tex2DNode106.r * tex2DNode106.g ) * _RGColor ) + ( ( tex2DNode107.r * tex2DNode107.b ) * _RBColor ) + ( ( tex2DNode108.g * tex2DNode108.b ) * _GBColor ) )).rgb , tex2D( _MainTex, uv_MainTex ).a));
				
				half4 color = appendResult26;
				
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
	CustomEditor "ColorChannelPaintShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
-100;-974;1644;933;2753.172;-828.5289;2.503683;True;False
Node;AmplifyShaderEditor.CommentaryNode;100;-1520.477,908.4475;Inherit;False;757;356;Pure Blue Channel;5;105;104;103;102;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-1521.477,303.4476;Inherit;False;757;356;Pure Green Channel;5;99;98;97;96;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;79;-1518.809,-254.8518;Inherit;False;757;356;Pure Red Channel;5;93;81;76;80;78;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;101;-1505.679,953.2068;Inherit;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;93;-1504.011,-210.0925;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;95;-1506.679,348.2069;Inherit;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1165.477,426.4476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1164.477,1031.448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1211.924,1970.034;Inherit;False;454.0538;333.3614;Red & Blue Channel Mix Modification;2;59;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-1213.565,2501.311;Inherit;False;452.7323;294.7983;Green & Blue Channel Mix Modification;2;68;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-1193.33,1459.636;Inherit;False;432.6215;315.3336;Red & Green Channel Mix Modification;2;38;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1162.809,-131.8518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;108;-1190.009,2590.294;Inherit;True;Property;_TextureSample6;Texture Sample 6;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1033.477,361.4476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1165.478,1127.448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-1032.477,966.4475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;107;-1186.009,2073.294;Inherit;True;Property;_TextureSample5;Texture Sample 5;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;106;-1173.009,1558.294;Inherit;True;Property;_TextureSample4;Texture Sample 4;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1166.478,522.4476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1029.809,-196.8518;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1163.81,-35.85181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-952.1735,1784.109;Inherit;False;Property;_RGColor;RGColor;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-942.2391,1275.372;Inherit;False;Property;_BColor;BColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-946.2478,110.213;Inherit;False;Property;_RColor;RColor;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-886.3072,1587.298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-895.4773,1078.448;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-893.0903,2115.073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-946.8909,669.213;Inherit;False;Property;_GColor;GColor;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;60;-943.7674,2313.506;Inherit;False;Property;_RBColor;RBColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-896.4773,473.4476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;73;-940.4084,2808.783;Inherit;False;Property;_GBColor;GBColor;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-893.8096,-84.85181;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-897.196,2609.781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-709.5653,2755.31;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-731.854,1201.552;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-734.854,611.5515;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-712.854,47.55151;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-716.3304,1689.936;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-717.9244,2250.033;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;154;-489.1375,1158.09;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;146;-507.6135,929.9933;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;155;-462.1375,1175.09;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;147;-472.6135,878.9933;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;153;-519.8162,1132.594;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;148;-529.6135,1071.993;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-228.4584,935.6561;Inherit;False;6;6;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-337.6516,1140.929;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;110;-71.92644,1059.142;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;3;-167.2053,1136.928;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;9a2f2a5aa824e465ebc74441a66801e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;26;167.2401,1101.854;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;143;419.8703,1101.451;Float;False;True;-1;2;ColorChannelPaintShaderEditor;0;6;mrvc/ColorChannelPaintShader;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;True;True;True;True;True;0;True;-9;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;96;0;95;1
WireConnection;96;1;95;2
WireConnection;102;0;101;1
WireConnection;102;1;101;3
WireConnection;78;0;93;1
WireConnection;78;1;93;2
WireConnection;98;0;95;2
WireConnection;98;1;96;0
WireConnection;103;0;101;2
WireConnection;103;1;101;3
WireConnection;104;0;101;3
WireConnection;104;1;102;0
WireConnection;97;0;95;2
WireConnection;97;1;95;3
WireConnection;76;0;93;1
WireConnection;76;1;78;0
WireConnection;80;0;93;1
WireConnection;80;1;93;3
WireConnection;38;0;106;1
WireConnection;38;1;106;2
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;59;0;107;1
WireConnection;59;1;107;3
WireConnection;99;0;98;0
WireConnection;99;1;97;0
WireConnection;81;0;76;0
WireConnection;81;1;80;0
WireConnection;68;0;108;2
WireConnection;68;1;108;3
WireConnection;69;0;68;0
WireConnection;69;1;73;0
WireConnection;18;0;105;0
WireConnection;18;1;11;0
WireConnection;17;0;99;0
WireConnection;17;1;12;0
WireConnection;9;0;81;0
WireConnection;9;1;10;0
WireConnection;51;0;38;0
WireConnection;51;1;32;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;154;0;61;0
WireConnection;146;0;17;0
WireConnection;155;0;69;0
WireConnection;147;0;9;0
WireConnection;153;0;51;0
WireConnection;148;0;18;0
WireConnection;109;0;147;0
WireConnection;109;1;146;0
WireConnection;109;2;148;0
WireConnection;109;3;153;0
WireConnection;109;4;154;0
WireConnection;109;5;155;0
WireConnection;110;0;109;0
WireConnection;3;0;2;0
WireConnection;26;0;110;0
WireConnection;26;3;3;4
WireConnection;143;0;26;0
ASEEND*/
//CHKSM=370F7B0EDD313800EE073267E0BBF5579AFC8EBC