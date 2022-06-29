// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/GrayscaleShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_GrayScaleAmount("GrayScaleAmount", Range( 0 , 1)) = 0
		_RedChannelBrightness("RedChannelBrightness", Range( -1 , 1)) = 0
		_BlueChannelBrightness("BlueChannelBrightness", Range( -1 , 1)) = 0
		_GreenChannelBrightness("GreenChannelBrightness", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
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
			uniform float4 _MainTex_ST;
			uniform float _RedChannelBrightness;
			uniform float _GreenChannelBrightness;
			uniform float _BlueChannelBrightness;
			uniform float _GrayScaleAmount;

			
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

				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
				float3 appendResult48 = (float3(( _RedChannelBrightness + 1.0 ) , ( _GreenChannelBrightness + 1.0 ) , ( _BlueChannelBrightness + 1.0 )));
				float3 appendResult34 = (float3(tex2DNode2.r , tex2DNode2.g , tex2DNode2.b));
				float dotResult36 = dot( ( appendResult48 * float3(0.299,0.587,0.114) ) , appendResult34 );
				float4 appendResult9 = (float4(dotResult36 , dotResult36 , dotResult36 , tex2DNode2.a));
				float4 lerpResult25 = lerp( tex2DNode2 , appendResult9 , _GrayScaleAmount);
				
				fixed4 c = lerpResult25;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "GrayscaleShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
358;534;1651;817;2006.037;456.2114;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;42;-1478.561,-215.329;Inherit;False;Property;_BlueChannelBrightness;BlueChannelBrightness;2;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1477.561,-291.3293;Inherit;False;Property;_GreenChannelBrightness;GreenChannelBrightness;3;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1477.561,-366.3292;Inherit;False;Property;_RedChannelBrightness;RedChannelBrightness;1;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1340.561,-141.3284;Inherit;False;Constant;_Remap;Remap;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1517.052,-12.3398;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1048.561,-360.3292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1048.561,-266.3293;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-1050.561,-173.3287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;35;-871.0419,-151.1988;Inherit;False;Constant;_GrayscaleBrightness;GrayscaleBrightness;3;0;Create;True;0;0;0;False;0;False;0.299,0.587,0.114;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;2;-1332.915,-11.259;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;0870238e2f6a227499908ac2c91231a7;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;48;-792.563,-288.3293;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-624.5415,18.60104;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-627.3633,-219.0288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;36;-402.5415,29.60104;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;37;-645.8428,128.9152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-377.7592,159.6646;Inherit;False;Property;_GrayScaleAmount;GrayScaleAmount;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-240.5796,6.40155;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;27;-148.3074,-38.55374;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StickyNoteNode;29;-368.8661,-233.9928;Inherit;False;401.3823;106.5125;For the Grayscale Formula;;1,1,1,1;http://support.ptc.com/help/mathcad/en/index.html#page/PTC_Mathcad_Help/example_grayscale_and_color_in_images.html;0;0
Node;AmplifyShaderEditor.LerpOp;25;-57.57483,-16.10434;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;110,-15;Float;False;True;-1;2;GrayscaleShaderEditor;0;8;mrvc/GrayscaleShader;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;45;0;41;0
WireConnection;45;1;44;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;47;0;42;0
WireConnection;47;1;44;0
WireConnection;2;0;1;0
WireConnection;48;0;45;0
WireConnection;48;1;46;0
WireConnection;48;2;47;0
WireConnection;34;0;2;1
WireConnection;34;1;2;2
WireConnection;34;2;2;3
WireConnection;40;0;48;0
WireConnection;40;1;35;0
WireConnection;36;0;40;0
WireConnection;36;1;34;0
WireConnection;37;0;2;4
WireConnection;9;0;36;0
WireConnection;9;1;36;0
WireConnection;9;2;36;0
WireConnection;9;3;37;0
WireConnection;27;0;2;0
WireConnection;25;0;27;0
WireConnection;25;1;9;0
WireConnection;25;2;28;0
WireConnection;0;0;25;0
ASEEND*/
//CHKSM=6A1F2737B73E9A8546645704449C74AF2A96D959