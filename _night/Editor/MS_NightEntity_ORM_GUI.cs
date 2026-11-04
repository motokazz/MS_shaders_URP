using UnityEngine;
using UnityEditor;

public class MS_NightEntity_ORM_GUI: ShaderGUI
{
    bool showBasic = true;
    bool showTweakColor = true;
    bool showFresnel = true;
    bool showDither = true;
    bool showOutline = true;
    bool showBlink = true;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        EditorGUILayout.HelpBox("【 ORM Workflow 】\nこのマテリアルは統合された ORM マップを使用します。\n（例: R=Occlusion, G=Roughness/Smoothness, B=Metallic）", MessageType.Info);
        EditorGUILayout.Space();
        //MaterialProperty cutoff = FindProperty("_Cutoff", properties);
        //materialEditor.ShaderProperty(cutoff, "Alpha Cutoff");

        // --------------------------------------------------
        // 1. Surface Inputs (基本設定)
        // --------------------------------------------------
        showBasic = EditorGUILayout.Foldout(showBasic, "=== Surface Inputs ===", true, EditorStyles.foldoutHeader);
        if (showBasic)
        {
            // プロパティの取得
            //MaterialProperty workflowMode = FindProperty("_WorkflowMode", properties);
            MaterialProperty baseMap = FindProperty("_BaseMap", properties);
            MaterialProperty baseColor = FindProperty("_BaseColor", properties);
            MaterialProperty metallicMap = FindProperty("_MetallicGlossMap", properties);
            MaterialProperty metallic = FindProperty("_Metallic", properties);
            MaterialProperty smoothness = FindProperty("_Smoothness", properties);
            MaterialProperty bumpMap = FindProperty("_BumpMap", properties);
            MaterialProperty bumpScale = FindProperty("_BumpScale", properties);
            //MaterialProperty occlusionMap = FindProperty("_OcclusionMap", properties);
            MaterialProperty occlusionScale = FindProperty("_OcclusionStrength", properties);
            MaterialProperty emissionMap = FindProperty("_EmissionMap", properties);
            MaterialProperty emissionColor = FindProperty("_EmissionColor", properties);

            // Workflow Mode
            //materialEditor.ShaderProperty(workflowMode, "Workflow Mode");
            EditorGUILayout.Space();

            // URP標準に合わせたテクスチャと値の1行表示（Tiling / Offset は自動的に隠れます）
            materialEditor.TexturePropertySingleLine(new GUIContent("Base Map"), baseMap, baseColor);

            materialEditor.TexturePropertySingleLine(new GUIContent("Metallic Map"), metallicMap, metallic);
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(smoothness, "Smoothness");
            materialEditor.ShaderProperty(occlusionScale, "occlusionScale");
            EditorGUI.indentLevel -= 2;

            materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), bumpMap, bumpScale);

            //materialEditor.TexturePropertySingleLine(new GUIContent("Occlusion Map"), occlusionMap, occlusionScale);
            materialEditor.TexturePropertySingleLine(new GUIContent("Emission"), emissionMap, emissionColor);

            EditorGUILayout.Space();

            // 最後に BaseMap の Tiling と Offset だけを描画
            materialEditor.TextureScaleOffsetProperty(baseMap);

        }

        EditorGUILayout.Space();

        // --------------------------------------------------
        // 2. Tweak Color
        // --------------------------------------------------
        showTweakColor = EditorGUILayout.Foldout(showTweakColor, "=== Tweak Color Settings ===", true, EditorStyles.foldoutHeader);
        if (showTweakColor)
        {
            materialEditor.ShaderProperty(FindProperty("_EnableTweakColor", properties), "Enable Tweak Color");
            MaterialProperty tweakMask = FindProperty("_TweakColorMask", properties);
            MaterialProperty tweakColor = FindProperty("_TweakColor", properties);

            // これにより TweakColorMask の Tiling / Offset も非表示になり、1行にまとまります
            materialEditor.TexturePropertySingleLine(new GUIContent("Tweak Color Mask"), tweakMask, tweakColor);
        }

        EditorGUILayout.Space();

        // --------------------------------------------------
        // 3. Fresnel Settings
        // --------------------------------------------------
        showFresnel = EditorGUILayout.Foldout(showFresnel, "=== Fresnel Settings ===", true, EditorStyles.foldoutHeader);
        if (showFresnel)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_EnableFresnel", properties), "Enable Fresnel");
            materialEditor.ShaderProperty(FindProperty("_FresnelColor", properties), "Fresnel Color");
            materialEditor.ShaderProperty(FindProperty("_FresnelPower", properties), "Fresnel Power");
            materialEditor.ShaderProperty(FindProperty("_FresnelIntensity", properties), "Fresnel Intensity");
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.Space();

        // --------------------------------------------------
        // 4. Dither Fade
        // --------------------------------------------------
        showDither = EditorGUILayout.Foldout(showDither, "=== Dither Fade Settings ===", true, EditorStyles.foldoutHeader);
        if (showDither)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_NearFadeEnable", properties), "Enable Near Dither Fade");
            materialEditor.ShaderProperty(FindProperty("_NearFadeStartDist", properties), "Near Fade Start Dist");
            materialEditor.ShaderProperty(FindProperty("_NearFadeEndDist", properties), "Near Fade End Dist");
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.Space();

        // --------------------------------------------------
        // 5. Outline Settings
        // --------------------------------------------------
        showOutline = EditorGUILayout.Foldout(showOutline, "=== Outline Settings ===", true, EditorStyles.foldoutHeader);
        if (showOutline)
        {
            EditorGUI.indentLevel++;

            materialEditor.ShaderProperty(FindProperty("_EnableOutlinePrime", properties), "Enable Outline");
            materialEditor.ShaderProperty(FindProperty("_OutlineWidth", properties), "Outline Width");
            materialEditor.ShaderProperty(FindProperty("_HeatPower", properties), "Heat Power");

            EditorGUILayout.Space();

            for (int i = 0; i < 6; i++)
            {
                EditorGUILayout.LabelField($"--- Heat Point {i} ---", EditorStyles.boldLabel);
                EditorGUI.indentLevel++;

                materialEditor.ShaderProperty(FindProperty($"_HeatColor{i}", properties), "Color");
                materialEditor.ShaderProperty(FindProperty($"_HeatWeight{i}", properties), "Weight");

                string posPropName = (i == 0) ? "_Pos" : $"_Pos{i}";
                materialEditor.ShaderProperty(FindProperty(posPropName, properties), "Position");

                EditorGUI.indentLevel--;
                EditorGUILayout.Space();
            }
            EditorGUI.indentLevel--;
        }
        EditorGUILayout.Space();

        // --------------------------------------------------
        // 6. Blink Settings
        // --------------------------------------------------
        showOutline = EditorGUILayout.Foldout(showBlink, "=== Blink Settings ===", true, EditorStyles.foldoutHeader);
        if (showBlink)
        {
            EditorGUI.indentLevel++;
            materialEditor.ShaderProperty(FindProperty("_EnableBlink", properties), "Enabe Blink Fresnel");
            materialEditor.ShaderProperty(FindProperty("_BlinkSpeed", properties), "Blink Speed");
            materialEditor.ShaderProperty(FindProperty("_BlinkMin", properties), "Blink Min");
            materialEditor.ShaderProperty(FindProperty("_BlinkMax", properties), "Blink Max");
            EditorGUI.indentLevel--;
        }



        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Advanced Options", EditorStyles.boldLabel);

        // 共通設定
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
    }
}