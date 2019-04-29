cbuffer cbPerFrame : register(b0)
{
	float d_near;
	float d_far;
	float d_focus;
	float far_clamp;
};

struct PSInput
{
	float4 Position : SV_POSITION;
	float3 Normal : NORMAL;
	float Depth : TEXCOORD1;
};

TextureCube tex : register(t0);
SamplerState smp : register(s0);

float ComputeDepthBlur (float depth)
{
   float f;

   if (depth < d_focus)
   {
      // scale depth value between near blur distance and focal distance to [-1, 0] range
      f = (depth - d_focus)/(d_focus - d_near);
   }
   else
   {
      // scale depth value between focal distance and far blur
      // distance to [0, 1] range
      f = (depth - d_focus)/(d_far - d_focus);

      // clamp the far blur to a maximum blurriness
      f = clamp (f, 0, far_clamp);
   }

   // scale and bias into [0, 1] range
   return f * 0.5f + 0.5f;
}

float4 main(PSInput pin) : SV_TARGET
{
	return float4(tex.Sample(smp, pin.Normal).xyz, ComputeDepthBlur(d_far));
}