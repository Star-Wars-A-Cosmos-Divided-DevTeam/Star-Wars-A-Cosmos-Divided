#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define INTERLACE_AMOUNT 0.1  // Ändere diesen Wert nach Bedarf

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float2 uv = input.uv;

    // Simuliere Interlacing durch Verschieben der Zeilen
    uv.y += sin(uv.y * PI) * INTERLACE_AMOUNT;

    // Überprüfe, ob die Koordinaten außerhalb des normalen Bereichs liegen
    if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
    {
        // Rückgabe einer transparenten Farbe für Koordinaten außerhalb des normalen Bereichs
        return float4(0, 0, 0, 0);
    }

    // Bilinear Sampling
    float4 color = _texture.Sample(_texture_SS, uv);

    color *= input.color;

    return color;
}
