using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoChangeColor : MonoBehaviour
{
    Material material;

    void Start()
    {
        material = GetComponent<Renderer>().sharedMaterial;
    }

    void Update()
    {
        float blackValue = Mathf.Cos( Time.time * 2f ) * 0.5f + 0.5f;
        material.SetColor( "_BorderColor", new Color( blackValue, 0f, 0f, 1 ) );
    }
}
