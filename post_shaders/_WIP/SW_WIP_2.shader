#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    // Bilinear Sampling für das vorhandene Bild
    float4 baseColor = _texture.Sample(_texture_SS, input.uv);

    // Erhöhe den Kontrast
    float contrastAmount = 1.5; // Ändere diesen Wert nach Bedarf
    baseColor.rgb = saturate((baseColor.rgb - 0.5) * contrastAmount + 0.5);

    // Ändere die Farbsättigung
    float saturationAmount = 0.8; // Ändere diesen Wert nach Bedarf
    baseColor.rgb = lerp(baseColor.rgb, grayscale(baseColor.rgb), saturationAmount);

    // Füge einen Blaustich hinzu
    float blueTintAmount = 0.1; // Ändere diesen Wert nach Bedarf
    baseColor.b += blueTintAmount;

    // Erhöhe die Helligkeit
    float brightnessAmount = 1.2; // Ändere diesen Wert nach Bedarf
    baseColor.rgb *= brightnessAmount;

    // Überprüfe, ob die Koordinaten außerhalb des normalen Bereichs liegen
    if (input.uv.x < 0 || input.uv.x > 1 || input.uv.y < 0 || input.uv.y > 1)
    {
        // Rückgabe einer transparenten Farbe für Koordinaten außerhalb des normalen Bereichs
        return float4(0, 0, 0, 0);
    }

    return baseColor;
}
