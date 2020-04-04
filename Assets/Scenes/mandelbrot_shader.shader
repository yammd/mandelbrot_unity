Shader "MandelBrot/mandelbrot_shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                col.rgb = col.rgb - (fixed4)(i.uv[0]-i.uv[1]);

		float2 z_n_plus_1;
		float2 z_n = (float2) 0;
		float2 z_2_n = (float2) 0;
		
		int max_loop = 1000;
		int is_in_mandelbrot_set = 0;
		int it=0;

		for(it=0; it<max_loop && is_in_mandelbrot_set == 0; it++) {
			z_2_n.x = (z_n.x*z_n.x - z_n.y*z_n.y);
			z_2_n.y = (2*z_n.x*z_n.y);
			z_n_plus_1.x = z_2_n.x + i.uv.x*2-1.5;
			z_n_plus_1.y = z_2_n.y + i.uv.y*2-1;

			if(sqrt(z_n_plus_1.x*z_n_plus_1.x + z_n_plus_1.y*z_n_plus_1.y) > 2) {
				is_in_mandelbrot_set = 1;
			} else {
				z_n = z_n_plus_1;
			}
		}

		if(is_in_mandelbrot_set == 0) {
			col.rgb = (fixed4) 0;
		} else {
			float palette = sqrt((float) it/10);
			col.rgb = fixed3(palette/3, palette/2 , palette);
		}

                return col;
            }
            ENDCG
        }
    }
}
