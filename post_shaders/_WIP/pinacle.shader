#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define WAVE_AMPLITUDE 0.05  // Ändere diesen Wert nach Bedarf
#define WAVE_FREQUENCY 1.0   // Ändere diesen Wert nach Bedarf
#define WAVE_SPEED 0.5       // Ändere diesen Wert nach Bedarf

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float2 uv = input.uv;

    // Simuliere eine Pixelverzerrungswelle von oben nach unten
    float waveOffset = sin(_time * WAVE_SPEED) * WAVE_AMPLITUDE;
    uv.y += waveOffset + sin(uv.x * WAVE_FREQUENCY) * WAVE_AMPLITUDE;

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
