// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/Blur"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		
	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{
			

			Blend Off

			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 appendResult27 = (float4(_MainTex_TexelSize.x , _MainTex_TexelSize.y , _MainTex_TexelSize.x , _MainTex_TexelSize.y));
				float4 appendResult102 = (float4(-1.0 , -1.0 , 1.0 , 1.0));
				float4 break9 = ( appendResult27 * appendResult102 );
				float2 appendResult13 = (float2(break9.x , break9.y));
				float4 tex2DNode20 = tex2D( _MainTex, ( uv_MainTex + appendResult13 ) );
				float3 appendResult28 = (float3(tex2DNode20.r , tex2DNode20.g , tex2DNode20.b));
				float2 appendResult15 = (float2(break9.x , break9.w));
				float4 tex2DNode21 = tex2D( _MainTex, ( uv_MainTex + appendResult15 ) );
				float3 appendResult29 = (float3(tex2DNode21.r , tex2DNode21.g , tex2DNode21.b));
				float2 appendResult14 = (float2(break9.z , break9.y));
				float4 tex2DNode23 = tex2D( _MainTex, ( uv_MainTex + appendResult14 ) );
				float3 appendResult31 = (float3(tex2DNode23.r , tex2DNode23.g , tex2DNode23.b));
				float2 appendResult16 = (float2(break9.z , break9.w));
				float4 tex2DNode22 = tex2D( _MainTex, ( uv_MainTex + appendResult16 ) );
				float3 appendResult30 = (float3(tex2DNode22.r , tex2DNode22.g , tex2DNode22.b));
				float4 appendResult91 = (float4(( ( appendResult28 + appendResult29 + appendResult31 + appendResult30 ) * float3( 0.25,0.25,0.25 ) ) , 1.0));
				

				finalColor = appendResult91;

				return finalColor;
			} 
			ENDCG 
		}
		
		
		Pass
		{
			Blend Off

			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 appendResult27 = (float4(_MainTex_TexelSize.x , _MainTex_TexelSize.y , _MainTex_TexelSize.x , _MainTex_TexelSize.y));
				float4 appendResult107 = (float4(-0.5 , -0.5 , 0.5 , 0.5));
				float4 break9 = ( appendResult27 * appendResult107 );
				float2 appendResult13 = (float2(break9.x , break9.y));
				float4 tex2DNode20 = tex2D( _MainTex, ( uv_MainTex + appendResult13 ) );
				float3 appendResult28 = (float3(tex2DNode20.r , tex2DNode20.g , tex2DNode20.b));
				float2 appendResult15 = (float2(break9.x , break9.w));
				float4 tex2DNode21 = tex2D( _MainTex, ( uv_MainTex + appendResult15 ) );
				float3 appendResult29 = (float3(tex2DNode21.r , tex2DNode21.g , tex2DNode21.b));
				float2 appendResult14 = (float2(break9.z , break9.y));
				float4 tex2DNode23 = tex2D( _MainTex, ( uv_MainTex + appendResult14 ) );
				float3 appendResult31 = (float3(tex2DNode23.r , tex2DNode23.g , tex2DNode23.b));
				float2 appendResult16 = (float2(break9.z , break9.w));
				float4 tex2DNode22 = tex2D( _MainTex, ( uv_MainTex + appendResult16 ) );
				float3 appendResult30 = (float3(tex2DNode22.r , tex2DNode22.g , tex2DNode22.b));
				float4 appendResult91 = (float4(( ( appendResult28 + appendResult29 + appendResult31 + appendResult30 ) * float3( 0.25,0.25,0.25 ) ) , 1.0));
				

				finalColor = appendResult91;

				return finalColor;
			} 
			ENDCG 
		}
		
		
		Pass
		{ 
			Blend Off
			
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				

				finalColor = half4( 1, 1, 1, 1 );

				return finalColor;
			} 
			ENDCG 
		}
		
		
		Pass
		{ 
			Blend Off
			
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			

			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				

				finalColor = half4( 1, 1, 1, 1 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
547;-1384;1792;1000;-962.3483;802.049;1;True;True
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;94;-956.5096,-359.6201;Inherit;False;0;0;_MainTex_TexelSize;Shader;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassSwitchNode;108;1339.459,-399.1606;Inherit;False;0;0;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StickyNoteNode;119;1848.629,-356.9481;Inherit;False;124;100;;;1,1,1,1;UpScale;0;0
Node;AmplifyShaderEditor.StickyNoteNode;118;1845.629,-466.9479;Inherit;False;124;100;;;1,1,1,1;DownScale;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;1152.05,-381.2397;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1007.366,-381.4147;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.25,0.25,0.25;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;859.3665,-382.4147;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;679.8018,-84.67139;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;688.8018,-658.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;679.8018,-275.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;679.8018,-468.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;20;398.3665,-688.4147;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;396.3665,-305.4147;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;392.3665,-114.4147;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;398.3665,-497.4147;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;18;93.36646,-258.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;93.36646,-487.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;89;-375.191,-652.9926;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;19;93.36646,-150.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;94.36646,-385.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-247.7854,-655.3783;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;13;-167.6335,-486.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-171.6335,-260.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-168.6335,-393.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-173.6335,-158.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;-369.6335,-339.4147;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;90;204.809,13.00745;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-498.6335,-337.4147;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;-1,-1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassSwitchNode;106;-867.2479,-125.8064;Inherit;False;0;0;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-742.1982,-352.6714;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1088.43,-194.9706;Inherit;False;FLOAT4;4;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-1091.248,-37.8064;Inherit;False;FLOAT4;4;0;FLOAT;-0.5;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;109;1676.973,-463.7239;Float;False;True;-1;2;ASEMaterialInspector;0;15;mrvc/Blur;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;4;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;111;1675.973,-171.7239;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 2;0;2;SubShader 0 Pass 2;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;110;1680.973,-339.7239;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 1;0;1;SubShader 0 Pass 1;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;112;1675.973,-93.72391;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 3;0;3;SubShader 0 Pass 3;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
WireConnection;108;0;91;0
WireConnection;108;1;91;0
WireConnection;91;0;26;0
WireConnection;26;0;25;0
WireConnection;25;0;28;0
WireConnection;25;1;29;0
WireConnection;25;2;31;0
WireConnection;25;3;30;0
WireConnection;30;0;22;1
WireConnection;30;1;22;2
WireConnection;30;2;22;3
WireConnection;28;0;20;1
WireConnection;28;1;20;2
WireConnection;28;2;20;3
WireConnection;31;0;23;1
WireConnection;31;1;23;2
WireConnection;31;2;23;3
WireConnection;29;0;21;1
WireConnection;29;1;21;2
WireConnection;29;2;21;3
WireConnection;20;0;90;0
WireConnection;20;1;12;0
WireConnection;23;0;90;0
WireConnection;23;1;18;0
WireConnection;22;0;90;0
WireConnection;22;1;19;0
WireConnection;21;0;90;0
WireConnection;21;1;17;0
WireConnection;18;0;38;0
WireConnection;18;1;14;0
WireConnection;12;0;38;0
WireConnection;12;1;13;0
WireConnection;19;0;38;0
WireConnection;19;1;16;0
WireConnection;17;0;38;0
WireConnection;17;1;15;0
WireConnection;38;2;89;0
WireConnection;13;0;9;0
WireConnection;13;1;9;1
WireConnection;14;0;9;2
WireConnection;14;1;9;1
WireConnection;15;0;9;0
WireConnection;15;1;9;3
WireConnection;16;0;9;2
WireConnection;16;1;9;3
WireConnection;9;0;7;0
WireConnection;7;0;27;0
WireConnection;7;1;106;0
WireConnection;106;0;102;0
WireConnection;106;1;107;0
WireConnection;27;0;94;1
WireConnection;27;1;94;2
WireConnection;27;2;94;1
WireConnection;27;3;94;2
WireConnection;109;0;108;0
WireConnection;110;0;108;0
ASEEND*/
//CHKSM=B808B99E250A5FC3EEBA058F7FE82AAD7E4DC6FD