using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class ShaderHandler : MonoBehaviour
{
    public Material mat;
    public Shader shadeee;

    public  Texture2D tex1, tex2, data;
    public RenderTexture rd;
    private Color[] array;
    private bool isTex1 = true;
    private float[] spectrum;
    public int fidelity = 1024;
    
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log(SystemInfo.maxTextureSize);
        tex2 = tex1 = new Texture2D(Screen.width, Screen.height, GraphicsFormat.R8G8B8A8_SRGB, TextureCreationFlags.None);
        array = tex1.GetPixels();
        for (int i = 0; i < array.Length; i++)
        {
            array[i] = Color.black;
        }
        tex1.SetPixels(array);
        tex1.Apply();
        tex2.SetPixels(array);
        tex2.Apply();
        
        spectrum  = new float[fidelity];
        data= new Texture2D(fidelity,1);
        Debug.Log(AudioSettings.outputSampleRate);
        QualitySettings.vSyncCount = 0;
        Application.targetFrameRate = 30;
    }
    
    void Update()
    {
        float[] spectrum = new float[256];

        AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);

        for (int i = 1; i < spectrum.Length - 1; i++)
        {
            Debug.DrawLine(new Vector3(i - 1, spectrum[i] + 10, 0), new Vector3(i, spectrum[i + 1] + 10, 0), Color.red);
            Debug.DrawLine(new Vector3(i - 1, Mathf.Log(spectrum[i - 1]) + 10, 2), new Vector3(i, Mathf.Log(spectrum[i]) + 10, 2), Color.cyan);
            Debug.DrawLine(new Vector3(Mathf.Log(i - 1), spectrum[i - 1] - 10, 1), new Vector3(Mathf.Log(i), spectrum[i] - 10, 1), Color.green);
            Debug.DrawLine(new Vector3(Mathf.Log(i - 1), Mathf.Log(spectrum[i - 1]), 3), new Vector3(Mathf.Log(i), Mathf.Log(spectrum[i]), 3), Color.blue);
        }
    }
    

    // Update is called once per frame

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(mat == null) {
            mat = new Material(shadeee);
            AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.Rectangular);
            mat.SetFloatArray("_data", spectrum);
            mat.SetTexture("_MainTex1", tex1);
            //mat.SetTexture("_MainTex2", tex2);
        }
        AudioListener.GetSpectrumData(spectrum, 0, FFTWindow.BlackmanHarris);
        Color[] Spectra = new Color[fidelity];
        for (int i = 0; i < fidelity; i++)
        {
            
            Spectra[i] = new Color(spectrum[i],spectrum[i],spectrum[i]);
        }
        data.SetPixels(Spectra);
        data.Apply();
        
        mat.SetTexture("_data", data);
        //mat.SetFloat("H", H);
        
        
        Graphics.Blit(source, destination, mat);
        RenderTexture.active = destination;

        
        

            tex1.SetPixels(array);
            //tex2.Apply();
            tex1.ReadPixels(new Rect(0, 0, destination.width, destination.height), 0, 0);
            tex1.Apply();
            isTex1 = !isTex1;
            mat.SetTexture("_MainTex1", tex1);
            //mat.SetTexture("_MainTex2", tex1);
        
        
    }
}
