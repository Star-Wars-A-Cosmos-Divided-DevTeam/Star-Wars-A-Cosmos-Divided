#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define SCALE_AMOUNT 1.0  // Ändere diesen Wert nach Bedarf

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float2 uv = input.uv * SCALE_AMOUNT;

    // Überprüfe, ob die Koordinaten außerhalb des normalen Bereichs liegen
    if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
    {
        // Rückgabe einer transparenten Farbe für Koordinaten außerhalb des normalen Bereichs
        return float4(0, 0, 0, 0);
    }

    // Bilinear Sampling für Skalierung mit etwas Anti-Aliasing
    float4 color = _texture.Sample(_texture_SS, uv);

    color *= input.color;

    return color;
}
