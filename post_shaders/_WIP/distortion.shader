#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define DISTORTION_AMOUNT 1.0   // Ändere diesen Wert nach Bedarf
#define DISTORTION_SPEED 1.0    // Ändere diesen Wert nach Bedarf

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    // Bilinear Sampling für das vorhandene Bild
    float4 baseColor = _texture.Sample(_texture_SS, input.uv);
    baseColor *= input.color;

    // Berechne die vertikale Position der Pixel für die Linienverzerrung
    float distortionOffset = sin(_time * DISTORTION_SPEED) * DISTORTION_AMOUNT;
    float2 distortedUV = input.uv;
    distortedUV.y += distortionOffset;

    // Zyklische Wiederholung der Verzerrung, wenn sie den unteren Bildrand erreicht
    if (distortedUV.y > 1.0)
    {
        distortedUV.y -= 1.0;
    }

    // Bilinear Sampling für die verzerrte Schicht
    float4 distortionColor = _texture.Sample(_texture_SS, distortedUV);
    
    // Kombiniere die beiden Schichten
    float4 finalColor = lerp(baseColor, distortionColor, 0.5);  // Mischung mit einem Verhältnis von 0.5

    // Überprüfe, ob die Koordinaten außerhalb des normalen Bereichs liegen
    if (input.uv.x < 0 || input.uv.x > 1 || input.uv.y < 0 || input.uv.y > 1)
    {
        // Rückgabe einer transparenten Farbe für Koordinaten außerhalb des normalen Bereichs
        return float4(0, 0, 0, 0);
    }

    return finalColor;
}
