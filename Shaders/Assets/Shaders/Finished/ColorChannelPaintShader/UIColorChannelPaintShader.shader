// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/UIColorChannelPaintShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_RColor("RColor", Color) = (1,1,1,1)
		_GColor("GColor", Color) = (1,1,1,1)
		_BColor("BColor", Color) = (1,1,1,1)
		_RGColor("RGColor", Color) = (1,1,1,1)
		_RBColor("RBColor", Color) = (1,1,1,1)
		_GBColor("GBColor", Color) = (1,1,1,1)

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
			#define ASE_NEEDS_FRAG_COLOR


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
			uniform half4 _RColor;
			uniform half4 _GColor;
			uniform half4 _BColor;
			uniform half4 _RGColor;
			uniform half4 _RBColor;
			uniform half4 _GBColor;

			
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

				half4 appendResult26 = (half4((( ( ( ( ( IN.color.r - ( IN.color.r * IN.color.g ) ) - ( IN.color.r * IN.color.b ) ) * _RColor ) + ( ( ( IN.color.g - ( IN.color.r * IN.color.g ) ) - ( IN.color.g * IN.color.b ) ) * _GColor ) + ( ( ( IN.color.b - ( IN.color.r * IN.color.b ) ) - ( IN.color.g * IN.color.b ) ) * _BColor ) ) + ( ( IN.color.r * IN.color.g ) * _RGColor ) + ( ( IN.color.r * IN.color.b ) * _RBColor ) + ( ( IN.color.g * IN.color.b ) * _GBColor ) )).rgb , IN.color.a));
				
				fixed4 c = appendResult26;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ColorChannelPaintShaderEditor"
	
	
}
/*ASEBEGIN
Version=18800
195;-1344;2096;1124;3649.797;625.8555;3.392603;True;True
Node;AmplifyShaderEditor.CommentaryNode;79;-1518.809,-254.8518;Inherit;False;757;356;Pure Red Channel;5;81;76;80;78;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-1521.477,303.4476;Inherit;False;757;356;Pure Green Channel;5;99;98;97;96;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;-1520.477,908.4475;Inherit;False;757;356;Pure Blue Channel;5;105;104;103;102;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;113;-1378.523,352.8146;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;114;-1377.523,957.8146;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;112;-1376.192,-203.739;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1165.477,426.4476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1164.477,1031.448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1162.809,-131.8518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1033.477,361.4476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1030.809,-196.8518;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1166.478,522.4476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1211.924,1970.034;Inherit;False;454.0538;333.3614;Red & Blue Channel Mix Modification;2;59;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-1193.33,1459.636;Inherit;False;432.6215;315.3336;Red & Green Channel Mix Modification;2;38;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-1032.477,966.4475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1165.478,1127.448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1163.81,-35.85181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;67;-1213.565,2501.311;Inherit;False;452.7323;294.7983;Green & Blue Channel Mix Modification;2;68;117;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;116;-1059.192,2078.955;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;115;-1045.192,1563.955;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;117;-1062.192,2595.955;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-893.8096,-84.85181;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-895.4773,1078.448;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-896.4773,473.4476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-946.8909,669.213;Inherit;False;Property;_GColor;GColor;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-946.2478,110.213;Inherit;False;Property;_RColor;RColor;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-942.2391,1275.372;Inherit;False;Property;_BColor;BColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-734.854,611.5515;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;60;-943.7674,2313.506;Inherit;False;Property;_RBColor;RBColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-896.196,2643.781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-893.0903,2115.073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-952.1735,1784.109;Inherit;False;Property;_RGColor;RGColor;3;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-731.854,1201.552;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-886.3072,1587.298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-712.854,47.55151;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;73;-940.4084,2808.783;Inherit;False;Property;_GBColor;GBColor;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.0491538,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-717.9244,2250.033;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-423.854,587.5515;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-716.3304,1702.636;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-709.5653,2755.31;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-69.45837,933.6561;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;110;196.6527,1057.142;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;111;228.8076,1145.261;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;26;435.8193,1099.854;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;576.4491,1098.451;Half;False;True;-1;2;ColorChannelPaintShaderEditor;0;8;mrvc/UIColorChannelPaintShader;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;96;0;113;1
WireConnection;96;1;113;2
WireConnection;102;0;114;1
WireConnection;102;1;114;3
WireConnection;78;0;112;1
WireConnection;78;1;112;2
WireConnection;98;0;113;2
WireConnection;98;1;96;0
WireConnection;76;0;112;1
WireConnection;76;1;78;0
WireConnection;97;0;113;2
WireConnection;97;1;113;3
WireConnection;104;0;114;3
WireConnection;104;1;102;0
WireConnection;103;0;114;2
WireConnection;103;1;114;3
WireConnection;80;0;112;1
WireConnection;80;1;112;3
WireConnection;81;0;76;0
WireConnection;81;1;80;0
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;99;0;98;0
WireConnection;99;1;97;0
WireConnection;17;0;99;0
WireConnection;17;1;12;0
WireConnection;68;0;117;2
WireConnection;68;1;117;3
WireConnection;59;0;116;1
WireConnection;59;1;116;3
WireConnection;18;0;105;0
WireConnection;18;1;11;0
WireConnection;38;0;115;1
WireConnection;38;1;115;2
WireConnection;9;0;81;0
WireConnection;9;1;10;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;22;0;9;0
WireConnection;22;1;17;0
WireConnection;22;2;18;0
WireConnection;51;0;38;0
WireConnection;51;1;32;0
WireConnection;69;0;68;0
WireConnection;69;1;73;0
WireConnection;109;0;22;0
WireConnection;109;1;51;0
WireConnection;109;2;61;0
WireConnection;109;3;69;0
WireConnection;110;0;109;0
WireConnection;26;0;110;0
WireConnection;26;3;111;4
WireConnection;0;0;26;0
ASEEND*/
//CHKSM=8554C1C5F0500180EB5AFCC0A4DD0CF73895F38B