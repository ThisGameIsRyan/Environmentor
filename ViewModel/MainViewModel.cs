using System.Numerics;
using System.Threading;
using System.ComponentModel;
using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Diagnostics;

namespace Environmentor.ViewModel;

public partial class MainViewModel : ObservableObject
{
    FileResult result;

    [ObservableProperty]
    string text;
    public void TextOutput(string _text)
    {
        Console.WriteLine("writing");
        Text = _text;
    }
    [RelayCommand]
    async void GetData()
    {

        try
        {
            Text = "Working...";
            result = await FilePicker.Default.PickAsync(new() { FileTypes = new FilePickerFileType(new Dictionary<DevicePlatform, IEnumerable<string>> { { DevicePlatform.WinUI, new[] { ".obj" } }, { DevicePlatform.macOS, new[] { "obj" } } }) });
        }
        catch (Exception)
        {
            // The user canceled or something went wrong
        }

        ObjConvertion oc = new ObjConvertion(result, new Callback(TextOutput));

        Thread thread = new Thread(new ThreadStart(oc.PickAndShow));
        thread.IsBackground = true;
        thread.Start();
        //thread.Join();
        //while (TextData == "Working...") { }
        //DataLb.Text = TextData;
        //SemanticScreenReader.Announce(DataLb.Text);
        //PickAndShow(new() { FileTypes = new FilePickerFileType(new Dictionary<DevicePlatform, IEnumerable<string>> { { DevicePlatform.WinUI, new[] { ".obj" } }, { DevicePlatform.macOS, new[] { "obj" } } }) });

    }

}
internal class TextData
{
    public string? Desc { get; set; }
}

public delegate void Callback(string text);

public class ObjConvertion
{
    private List<Vector3>? vertices;
    private List<Vector3>? faces;
    private Callback callback;
    public string AllOfTexts = "";

    Vector3 a = Vector3.Zero;
    Vector3 b = Vector3.Zero;
    Vector3 c = Vector3.Zero;
    Vector3 d = Vector3.Zero;
    Vector3 e = Vector3.Zero;
    float ab = 0;
    float bc = 0;
    float ca = 0;
    float ad = 0;
    float ae = 0;
    float fb = 0;
    float scaleY = 0;
    float scaleX = 0;
    Vector3 rot = Vector3.Zero;
    Vector3 Pos = Vector3.Zero;

    private FileResult result;

    public ObjConvertion(FileResult file, Callback callbackDelegate)
    {
        result = file;
        callback = callbackDelegate;
    }

    public async void PickAndShow()
    {
        var stopwatch = new Stopwatch();
        stopwatch.Start();
        if (result != null)
        {
            if (result.FileName.EndsWith("obj", StringComparison.OrdinalIgnoreCase))
            {
                AllOfTexts = "";
                vertices = new List<Vector3>();
                faces = new List<Vector3>();
                string track = "";
                List<TextData> ItemDets = new List<TextData>();
                using var stream = await result.OpenReadAsync();
                using StreamReader sr = new(stream);

                string? line;
                while ((line = sr.ReadLine()) != null)
                {
                    if (line == "")
                    {
                        continue;
                    }

                    string[] parts = line.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

                    if (line[0] == 'o')
                    {
                        track = parts[1];
                    }
                    else if (line[0] == 'v')
                    {
                        vertices.Add(new Vector3(float.Parse(parts[1], System.Globalization.CultureInfo.InvariantCulture), float.Parse(parts[2], System.Globalization.CultureInfo.InvariantCulture), float.Parse(parts[3], System.Globalization.CultureInfo.InvariantCulture)));
                    }
                    else if (line[0] == 'f')
                    {
                        faces.Add(new Vector3(float.Parse(parts[1].Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries)[0], System.Globalization.CultureInfo.InvariantCulture), float.Parse(parts[2].Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries)[0], System.Globalization.CultureInfo.InvariantCulture), float.Parse(parts[3].Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries)[0], System.Globalization.CultureInfo.InvariantCulture)));
                    }
                    else
                    {
                        //Console.WriteLine(line);
                        continue;
                    }
                }
                for (int i = 0; i < faces.Count; i++)
                {
                    Console.WriteLine(faces[i] - Vector3.One);
                    AllOfTexts += "{\"geometry\": {\"type\": \"Triangle\",\"material\": \"black\"}, \"track\": \"" + track + "\", ";
                    rot = Vector3.Zero;
                    a = vertices[(int)faces[i].X - 1];
                    b = vertices[(int)faces[i].Y - 1];
                    c = vertices[(int)faces[i].Z - 1];
                    Console.WriteLine($"{a} {b} {c}");
                    ab = MathF.Sqrt(MathF.Pow(b.X - a.X, 2) + MathF.Pow(b.Y - a.Y, 2) + MathF.Pow(b.Z - a.Z, 2));
                    bc = MathF.Sqrt(MathF.Pow(c.X - b.X, 2) + MathF.Pow(c.Y - b.Y, 2) + MathF.Pow(c.Z - b.Z, 2));
                    ca = MathF.Sqrt(MathF.Pow(a.X - c.X, 2) + MathF.Pow(a.Y - c.Y, 2) + MathF.Pow(a.Z - c.Z, 2));


                    if (ab >= bc && ab >= ca)
                    {
                        // ab longest
                        Console.WriteLine("Use c");
                        d = new Vector3(a.X - (ca * (a.X - b.X) / ab), a.Y - (ca * (a.Y - b.Y) / ab), a.Z - (ca * (a.Z - b.Z) / ab));
                        //e = new Vector3(c.X - (ca * (c.X - b.X) / bc), c.Y - (ca * (c.Y - b.Y) / bc), c.Z - (ca * (c.Z - b.Z) / bc));
                        Vector3 f = (c + d) / 2;
                        ad = MathF.Sqrt(MathF.Pow(c.X - d.X, 2) + MathF.Pow(c.Y - d.Y, 2) + MathF.Pow(c.Z - d.Z, 2));
                        //ae = MathF.Sqrt(MathF.Pow(a.X - e.X, 2) + MathF.Pow(a.Y - e.Y, 2) + MathF.Pow(a.Z - e.Z, 2));
                        fb = MathF.Sqrt(MathF.Pow(a.X - f.X, 2) + MathF.Pow(a.Y - f.Y, 2) + MathF.Pow(a.Z - f.Z, 2));

                        // Scale
                        scaleY = fb;
                        scaleX = ad;

                        // Position: center point of side ad then center point of side adb
                        Pos = (a + f) / 2;
                        AllOfTexts += "\"position\": [" + Pos.Z + "," + Pos.Y + "," + Pos.X + "], ";

                        // Rotation
                        rot = (a - f) / fb;
                        rot = new Vector3((float)(Math.Acos(rot.Y) * (180 / Math.PI) + 180), (float)(Math.Acos(rot.Y) * (180 / Math.PI)), (float)(Math.Acos(rot.Z) * (180 / Math.PI) + 180));
                    }
                    else if (bc >= ca && bc >= ab)
                    {
                        // bc longest
                        Console.WriteLine("Use a");
                        d = new Vector3(b.X - (ab * (b.X - c.X) / bc), b.Y - (ab * (b.Y - c.Y) / bc), b.Z - (ab * (b.Z - c.Z) / bc));
                        //e = new Vector3(c.X - (ca * (c.X - b.X) / bc), c.Y - (ca * (c.Y - b.Y) / bc), c.Z - (ca * (c.Z - b.Z) / bc));
                        Vector3 f = (a + d) / 2;
                        ad = MathF.Sqrt(MathF.Pow(a.X - d.X, 2) + MathF.Pow(a.Y - d.Y, 2) + MathF.Pow(a.Z - d.Z, 2));
                        //ae = MathF.Sqrt(MathF.Pow(a.X - e.X, 2) + MathF.Pow(a.Y - e.Y, 2) + MathF.Pow(a.Z - e.Z, 2));
                        fb = MathF.Sqrt(MathF.Pow(b.X - f.X, 2) + MathF.Pow(b.Y - f.Y, 2) + MathF.Pow(b.Z - f.Z, 2));

                        // Scale
                        scaleY = fb;
                        scaleX = ad;

                        // Position: center point of side ad then center point of side adb
                        Pos = (b + f) / 2;
                        AllOfTexts += "\"position\": [" + Pos.Z + "," + Pos.Y + "," + Pos.X + "], ";

                        // Rotation
                        rot = (b - f) / fb;
                        rot = new Vector3((float)(Math.Acos(rot.Y) * (180 / Math.PI) + 180), (float)(Math.Acos(rot.Y) * (180 / Math.PI)), (float)(Math.Acos(rot.Z) * (180 / Math.PI) + 180));
                    }
                    else if (ca >= bc && ca >= ab)
                    {
                        // ca longest
                        Console.WriteLine("use b");
                        d = new Vector3(c.X - (bc * (c.X - a.X) / ca), c.Y - (bc * (c.Y - a.Y) / ca), c.Z - (bc * (c.Z - a.Z) / ca));
                        //e = new Vector3(c.X - (bc * (c.X - a.X) / ca), c.Y - (bc * (c.Y - a.Y) / ca), c.Z - (bc * (c.Z - a.Z) / ca));
                        Vector3 f = (b + d) / 2;
                        ad = MathF.Sqrt(MathF.Pow(b.X - d.X, 2) + MathF.Pow(b.Y - d.Y, 2) + MathF.Pow(b.Z - d.Z, 2));
                        //ae = MathF.Sqrt(MathF.Pow(b.X - e.X, 2) + MathF.Pow(b.Y - e.Y, 2) + MathF.Pow(b.Z - e.Z, 2));
                        fb = MathF.Sqrt(MathF.Pow(c.X - f.X, 2) + MathF.Pow(c.Y - f.Y, 2) + MathF.Pow(c.Z - f.Z, 2));

                        // Scale
                        scaleY = fb;
                        scaleX = ad;

                        // Position: center point of side ad then center point of side adb
                        Pos = (c + f) / 2;
                        AllOfTexts += "\"position\": [" + Pos.Z + "," + Pos.Y + "," + Pos.X + "], ";

                        // Rotation
                        rot = (c - f) / fb;
                        rot = new Vector3((float)(Math.Acos(rot.Y) * (180 / Math.PI) + 180), (float)(Math.Acos(rot.Y) * (180 / Math.PI)), -1 * (float)(Math.Acos(rot.Z) * (180 / Math.PI) + 180));
                    }
                    AllOfTexts += "\"rotation\": [" + rot.X + "," + rot.Y + "," + rot.Z + "],";
                    AllOfTexts += "\"scale\": [" + scaleX + "," + scaleY + ",1]}";

                    if (i != faces.Count - 1)
                    {
                        AllOfTexts += ",";
                    }
                }
                callback(AllOfTexts);
                Console.WriteLine(AllOfTexts);
            }
        }
        stopwatch.Stop();
        Console.WriteLine(stopwatch.ElapsedMilliseconds + "ms");
    }
}