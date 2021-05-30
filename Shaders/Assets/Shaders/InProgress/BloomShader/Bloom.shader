// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "mrvc/Bloom"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
			
			uniform sampler2D _SourceTex;
			uniform float4 _SourceTex_ST;
			uniform float _Intensity;


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
				float2 uv_SourceTex = i.uv.xy * _SourceTex_ST.xy + _SourceTex_ST.zw;
				float4 tex2DNode114 = tex2D( _SourceTex, uv_SourceTex );
				float3 appendResult120 = (float3(tex2DNode114.r , tex2DNode114.g , tex2DNode114.b));
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
				float4 break116 = appendResult91;
				float3 appendResult117 = (float3(break116.x , break116.y , break116.z));
				float3 temp_output_152_0 = ( appendResult117 * _Intensity );
				float4 appendResult121 = (float4(( appendResult120 + temp_output_152_0 ) , tex2DNode114.a));
				

				finalColor = appendResult121;

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
			
			uniform float4 _Filter;
			float3 PreFilter148( float3 color, float4 filter )
			{
				half brightness = max(color.r, max(color.g, color.b));
				half soft = brightness - filter.y;
				soft = clamp(soft, 0, filter.z);
				soft = soft * soft / filter.w;
				half contribution = max(soft, brightness - filter.x);
				contribution /= max(brightness, 0.00001);
				return color * contribution;
			}
			


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
				float4 break128 = appendResult91;
				float3 appendResult149 = (float3(break128.x , break128.y , break128.z));
				float3 color148 = appendResult149;
				float4 filter148 = _Filter;
				float3 localPreFilter148 = PreFilter148( color148 , filter148 );
				float4 appendResult140 = (float4(localPreFilter148 , 1.0));
				

				finalColor = appendResult140;

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
			Blend One One
			
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
			
			uniform float _Intensity;


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
				float4 break116 = appendResult91;
				float3 appendResult117 = (float3(break116.x , break116.y , break116.z));
				float3 temp_output_152_0 = ( appendResult117 * _Intensity );
				float4 appendResult153 = (float4(temp_output_152_0 , 1.0));
				

				finalColor = appendResult153;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18800
198;-1343;2096;1124;-575.2521;1082.64;1.1;True;False
Node;AmplifyShaderEditor.DynamicAppendNode;102;-1015.43,-270.9706;Inherit;False;FLOAT4;4;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-1018.248,-113.8064;Inherit;False;FLOAT4;4;0;FLOAT;-0.5;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;94;-883.51,-435.6201;Inherit;False;0;0;_MainTex_TexelSize;Shader;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;27;-669.198,-428.6714;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassSwitchNode;106;-794.248,-201.8064;Inherit;False;0;0;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-498.6335,-337.4147;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;-1,-1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;89;-375.191,-652.9926;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;9;-369.6335,-339.4147;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;16;-173.6335,-158.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-247.7854,-655.3783;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;14;-171.6335,-260.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-167.6335,-486.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-168.6335,-393.4147;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;93.36646,-258.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;93.36646,-150.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;94.36646,-385.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;93.36646,-487.4147;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;90;204.809,13.00745;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;392.3665,-114.4147;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;399.4821,-688.4005;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;398.3665,-497.4147;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;396.3665,-305.4147;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;29;679.8018,-468.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;30;679.8018,-84.67139;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;679.8018,-275.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;688.8018,-658.6714;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;859.3665,-382.4147;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;1007.366,-381.4147;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.25,0.25,0.25;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;1152.05,-381.2397;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;116;1305.7,-592.6989;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;151;1388.492,-434.4026;Inherit;False;Global;_Intensity;_Intensity;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;114;1153.359,-858.7188;Inherit;True;Global;_SourceTex;_SourceTex;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;128;1320.659,-171.7385;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;117;1417.7,-576.699;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;149;1443.422,-172.6347;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;1596.052,-533.7403;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;1445.359,-846.7188;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;150;1389.391,-18.50245;Inherit;False;Global;_Filter;_Filter;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;148;1674.884,-171.9359;Inherit;False;half brightness = max(color.r, max(color.g, color.b))@$half soft = brightness - filter.y@$soft = clamp(soft, 0, filter.z)@$soft = soft * soft / filter.w@$half contribution = max(soft, brightness - filter.x)@$contribution /= max(brightness, 0.00001)@$return color * contribution@;3;False;2;True;color;FLOAT3;0,0,0;In;;Inherit;False;True;filter;FLOAT4;0,0,0,0;In;;Inherit;False;PreFilter;True;False;0;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;1789.558,-596.2202;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;153;1862.252,-309.3396;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;1906.558,-591.2202;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;140;1923.357,-174.5359;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StickyNoteNode;125;2694.95,-476.1996;Inherit;False;124;100;;;1,1,1,1;PreFilter;0;0
Node;AmplifyShaderEditor.StickyNoteNode;126;2693.95,-367.1996;Inherit;False;124;100;;;1,1,1,1;DownScale;0;0
Node;AmplifyShaderEditor.StickyNoteNode;124;2695.95,-587.1995;Inherit;False;124;100;;;1,1,1,1;Bloom;0;0
Node;AmplifyShaderEditor.StickyNoteNode;127;2692.95,-257.1996;Inherit;False;124;100;;;1,1,1,1;UpScale;0;0
Node;AmplifyShaderEditor.TemplateMultiPassSwitchNode;108;2151.164,-449.8317;Inherit;False;0;0;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;110;2524.689,-455.8727;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 1;0;1;SubShader 0 Pass 1;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;109;2526.407,-583.296;Float;False;True;-1;2;ASEMaterialInspector;0;15;mrvc/Bloom;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;4;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;123;2525.972,-242.2021;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 3;0;3;SubShader 0 Pass 3;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;111;2523.689,-346.7551;Float;False;False;-1;2;ASEMaterialInspector;0;15;New Amplify Shader;958921d600d7d45bf8d5d0d9cb5b541d;True;SubShader 0 Pass 2;0;2;SubShader 0 Pass 2;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;False;0
WireConnection;27;0;94;1
WireConnection;27;1;94;2
WireConnection;27;2;94;1
WireConnection;27;3;94;2
WireConnection;106;0;107;0
WireConnection;106;1;102;0
WireConnection;106;2;102;0
WireConnection;106;3;107;0
WireConnection;7;0;27;0
WireConnection;7;1;106;0
WireConnection;9;0;7;0
WireConnection;16;0;9;2
WireConnection;16;1;9;3
WireConnection;38;2;89;0
WireConnection;14;0;9;2
WireConnection;14;1;9;1
WireConnection;13;0;9;0
WireConnection;13;1;9;1
WireConnection;15;0;9;0
WireConnection;15;1;9;3
WireConnection;18;0;38;0
WireConnection;18;1;14;0
WireConnection;19;0;38;0
WireConnection;19;1;16;0
WireConnection;17;0;38;0
WireConnection;17;1;15;0
WireConnection;12;0;38;0
WireConnection;12;1;13;0
WireConnection;22;0;90;0
WireConnection;22;1;19;0
WireConnection;20;0;90;0
WireConnection;20;1;12;0
WireConnection;21;0;90;0
WireConnection;21;1;17;0
WireConnection;23;0;90;0
WireConnection;23;1;18;0
WireConnection;29;0;21;1
WireConnection;29;1;21;2
WireConnection;29;2;21;3
WireConnection;30;0;22;1
WireConnection;30;1;22;2
WireConnection;30;2;22;3
WireConnection;31;0;23;1
WireConnection;31;1;23;2
WireConnection;31;2;23;3
WireConnection;28;0;20;1
WireConnection;28;1;20;2
WireConnection;28;2;20;3
WireConnection;25;0;28;0
WireConnection;25;1;29;0
WireConnection;25;2;31;0
WireConnection;25;3;30;0
WireConnection;26;0;25;0
WireConnection;91;0;26;0
WireConnection;116;0;91;0
WireConnection;128;0;91;0
WireConnection;117;0;116;0
WireConnection;117;1;116;1
WireConnection;117;2;116;2
WireConnection;149;0;128;0
WireConnection;149;1;128;1
WireConnection;149;2;128;2
WireConnection;152;0;117;0
WireConnection;152;1;151;0
WireConnection;120;0;114;1
WireConnection;120;1;114;2
WireConnection;120;2;114;3
WireConnection;148;0;149;0
WireConnection;148;1;150;0
WireConnection;115;0;120;0
WireConnection;115;1;152;0
WireConnection;153;0;152;0
WireConnection;121;0;115;0
WireConnection;121;3;114;4
WireConnection;140;0;148;0
WireConnection;108;0;121;0
WireConnection;108;1;140;0
WireConnection;108;2;91;0
WireConnection;108;3;153;0
WireConnection;110;0;108;0
WireConnection;109;0;108;0
WireConnection;123;0;108;0
WireConnection;111;0;108;0
ASEEND*/
//CHKSM=E40FB6C148BE6F18BC2BB99F3FC0D590AC020E65