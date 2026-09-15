import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

abstract class GeminiRemoteDataSource {
  Future<String> generateHealthResponse(
    String userPrompt,
    List<Map<String, String>> previousHistory, {
    String? patientContext,
  });
}

@LazySingleton(as: GeminiRemoteDataSource)
class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final Dio _dio;
  final bool enableRemote;

  GeminiRemoteDataSourceImpl({Dio? dio, this.enableRemote = true})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                sendTimeout: const Duration(seconds: 8),
              ),
            );

  static String _buildSystemInstruction(String? patientContext) {
    final buffer = StringBuffer();
    buffer.write(
      "You are Afya AI (Afya Agent), the dedicated, compassionate, and knowledgeable health and wellness AI assistant in the Afya digital healthcare ecosystem. "
      "Your purpose is to provide patients with reliable medical knowledge, medication education, and psychological and emotional wellness guidance.\n\n"
      "CORE CAPABILITIES & ROLES:\n"
      "1. AFYA AGENT IDENTITY: Explicitly represent yourself as Afya's health assistant. Maintain a supportive, warm, culturally sensitive, and respectful tone.\n"
      "2. MEDICAL INFORMATION: Provide rich, evidence-based, and easy-to-understand explanations of human anatomy, diseases, symptoms, physiological processes, and wellness practices. Do NOT be overly restrictive or evasive; answer thoroughly and educate the patient with practical insights.\n"
      "3. MEDICATIONS & PHARMACOLOGY: Actively discuss medications. Explain their therapeutic purposes, general mechanisms of action, standard schedules, potential side effects, food/drug interactions to watch out for, and the importance of medication adherence. Provide helpful general guidance on what to do if a dose is missed (e.g., take when remembered unless near the next dose, do not double up).\n"
      "4. PSYCHOLOGY & MENTAL HEALTH: Offer empathetic, evidence-based psychological support for stress, anxiety, burnout, low mood, grief, and emotional challenges. Share actionable coping strategies such as grounding techniques (e.g., 5-4-3-2-1 sensory grounding), breathwork (4-7-8 breathing, box breathing), thought reframing, and sleep hygiene. Validate emotions warmly.\n"
      "5. ENGAGE THE PATIENT: Discuss the patient's questions, daily routine, and their medications naturally. Help them understand what to ask their physician.\n"
      "6. NON-DIAGNOSTIC BOUNDARY: You MUST NOT issue formal clinical diagnoses (e.g., never state 'You have condition X') or prescribe specific dosages. Frame medical explanations in terms of educational possibilities to investigate. Always guide the patient to consult their Afya clinic doctor or healthcare professional for official diagnosis, clinical evaluation, or treatment changes.\n"
      "7. EMERGENCY PROTOCOL: If the patient describes acute, potentially life-threatening emergencies (e.g., severe chest pressure, sudden numbness/paralysis, acute respiratory distress, severe allergic reactions, or acute self-harm/suicide risk), immediately urge them with care to call emergency services or a crisis lifeline right away.",
    );

    if (patientContext != null && patientContext.trim().isNotEmpty) {
      buffer.write(
        "\n\n[PATIENT CLINICAL & MEDICATION PROFILE IN AFYA]\n$patientContext\n"
        "Use this context to accurately and personally discuss the patient's medications, schedule, and questions when relevant.",
      );
    }

    return buffer.toString();
  }

  @override
  Future<String> generateHealthResponse(
    String userPrompt,
    List<Map<String, String>> previousHistory, {
    String? patientContext,
  }) async {
    final apiKey =
        dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['GEMINI_KEY'] ?? '';

    if (enableRemote && apiKey.trim().isNotEmpty) {
      final modelsToTry = [
        'gemini-2.5-flash',
        'gemini-flash-latest',
        'gemini-3.6-flash',
      ];

      final contents = <Map<String, dynamic>>[];

      // Previous conversation history
      for (final item in previousHistory) {
        final role = item['role'] == 'user' ? 'user' : 'model';
        final text = item['text'] ?? '';
        if (text.isNotEmpty) {
          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ]
          });
        }
      }

      // Current user prompt
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userPrompt}
        ]
      });

      final payload = {
        'system_instruction': {
          'parts': [
            {'text': _buildSystemInstruction(patientContext)}
          ]
        },
        'contents': contents,
      };

      for (final modelName in modelsToTry) {
        try {
          final url =
              'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=${apiKey.trim()}';

          final response = await _dio.post(
            url,
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) => status != null && status < 500,
            ),
            data: payload,
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data is String
                ? jsonDecode(response.data)
                : response.data;

            final candidates = data['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final content = candidates[0]['content'];
              final parts = content['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts[0]['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  return text;
                }
              }
            }
          } else if (response.statusCode == 400 || response.statusCode == 403) {
            // Invalid API key or unauthorized — fall back immediately
            break;
          }
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.response?.statusCode == 400 ||
              e.response?.statusCode == 403) {
            // Network unavailable or key invalid — fall back immediately
            break;
          }
        } catch (_) {
          break;
        }
      }
    }

    // Intelligent health, medication, and psychology response when GEMINI_API_KEY is not yet added or offline
    return _generateFallbackHealthResponse(userPrompt,
        patientContext: patientContext);
  }

  String _generateFallbackHealthResponse(String prompt,
      {String? patientContext}) {
    final lower = prompt.toLowerCase();

    // 1. Patient's Specific Medications query
    if ((lower.contains('my med') ||
            lower.contains('what medication') ||
            lower.contains('my prescription') ||
            lower.contains('what pills') ||
            lower.contains('my drugs')) &&
        patientContext != null &&
        patientContext.contains('Active Prescriptions')) {
      return "Hello! As your **Afya Agent**, I reviewed your current prescriptions recorded in the Afya app:\n\n"
          "$patientContext\n\n"
          "**Medication Advice & Adherence:**\n"
          "• Take your medicines according to the exact instructions and times shown above.\n"
          "• If you experience unusual side effects or have trouble taking any dose, please notify your prescribing doctor.\n"
          "• Do not stop or alter your dosage without consulting your clinic first.\n\n"
          "*Disclaimer: This summary is educational and based on your active Afya health records. It does not replace clinical consultation with your healthcare provider.*";
    }

    // 2. Missed Dose Questions
    if (lower.contains('missed') ||
        lower.contains('forgot to take') ||
        lower.contains('skip a dose')) {
      return "As your **Afya Agent**, here are the standard general medical guidelines for missed medication doses:\n\n"
          "**General Missed-Dose Protocol:**\n"
          "• **Take it as soon as you remember**, unless it is almost time for your next scheduled dose.\n"
          "• **Never double up:** Do not take two doses at once to make up for a forgotten pill, as this can increase toxicity or side effect risks.\n"
          "• **Check the patient leaflet:** Certain medications (such as oral contraceptives, insulin, or blood thinners) have specialized protocols.\n"
          "• **Track it in Afya:** Mark missed or taken doses in your Afya medication adherence schedule so your doctor has an accurate record.\n\n"
          "*If you are unsure or frequently forget doses, contact your clinic or pharmacist for personalized instructions.*";
    }

    // 3. Specific Medications
    if (lower.contains('paracetamol') ||
        lower.contains('acetaminophen') ||
        lower.contains('panadol') ||
        lower.contains('tylenol')) {
      return "**Paracetamol (Acetaminophen) Overview — from Afya Agent:**\n\n"
          "• **Purpose:** Analgesic and antipyretic used to relieve mild-to-moderate pain (headaches, muscular aches, toothaches) and reduce fever.\n"
          "• **Typical Adult Dosage:** Commonly 500mg to 1,000mg every 4 to 6 hours as needed (maximum 4,000mg per 24 hours).\n"
          "• **Key Precautions:**\n"
          "  - Avoid combining with other cough/cold products that also contain paracetamol to prevent accidental overdose.\n"
          "  - Caution in individuals with liver conditions or heavy alcohol consumption.\n\n"
          "*Always read the product packaging and consult your doctor or pharmacist for specific guidance.*";
    }

    if (lower.contains('ibuprofen') ||
        lower.contains('advil') ||
        lower.contains('motrin') ||
        lower.contains('nsaid')) {
      return "**Ibuprofen (NSAID) Overview — from Afya Agent:**\n\n"
          "• **Purpose:** Non-steroidal anti-inflammatory drug (NSAID) used to treat pain, inflammation, swelling, and fever.\n"
          "• **Administration:** Best taken **with or immediately after food or milk** to minimize stomach upset.\n"
          "• **Common Side Effects:** Mild stomach irritation, heartburn, or nausea.\n"
          "• **Precautions:** Avoid or use with caution if you have a history of stomach ulcers, kidney disease, severe asthma, or are taking blood thinners.\n\n"
          "*Consult your physician or pharmacist regarding drug interactions with your current prescriptions.*";
    }

    if (lower.contains('antibiotic') ||
        lower.contains('amoxicillin') ||
        lower.contains('penicillin') ||
        lower.contains('azithromycin')) {
      return "**Antibiotic Guidance — from Afya Agent:**\n\n"
          "• **Purpose:** Antibiotics treat bacterial infections. They are **ineffective against viral infections** like the common cold, flu, or COVID-19.\n"
          "• **Critical Rule:** **Complete the full prescribed course**, even if you feel completely recovered earlier. Stopping prematurely promotes antibiotic resistance.\n"
          "• **Side Effects:** Mild gastrointestinal symptoms (loose stools, nausea) are common. Taking probiotics or yogurt during and after the course may support gut health.\n"
          "• **Allergy Warning:** If you develop a rash, hives, swelling of the face, or difficulty breathing, stop immediately and seek emergency medical care.\n\n"
          "*Always take antibiotics strictly under a licensed doctor's prescription.*";
    }

    if (lower.contains('metformin') || lower.contains('diabetes med')) {
      return "**Metformin Overview — from Afya Agent:**\n\n"
          "• **Purpose:** An oral biguanide used as a first-line treatment to improve insulin sensitivity and lower blood glucose in Type 2 Diabetes.\n"
          "• **Best Practice:** Take **with meals** to reduce initial gastrointestinal side effects like bloating, nausea, or loose stools.\n"
          "• **Monitoring:** Regular monitoring of HbA1c and kidney function is standard clinical practice.\n\n"
          "*Never alter your diabetes medication dose without consulting your endocrinologist or primary doctor.*";
    }

    if (lower.contains('omeprazole') ||
        lower.contains('antacid') ||
        lower.contains('acid reflux') ||
        lower.contains('gerd') ||
        lower.contains('pantoprazole')) {
      return "**Proton Pump Inhibitors (e.g., Omeprazole) — from Afya Agent:**\n\n"
          "• **Purpose:** Reduces stomach acid production to treat acid reflux (GERD), heartburn, and gastritis, and protect against ulcers.\n"
          "• **Timing:** Best taken in the morning **30 to 60 minutes before your first meal**.\n"
          "• **Lifestyle Support:** Avoid eating within 2-3 hours of lying down, elevate the head of your bed, and limit trigger foods (spicy, acidic, or fatty meals).\n\n"
          "*Discuss long-term acid suppression therapy with your healthcare provider.*";
    }

    // 4. Psychology & Mental Health
    if (lower.contains('anxious') ||
        lower.contains('anxiety') ||
        lower.contains('panic') ||
        lower.contains('worry') ||
        lower.contains('nervous') ||
        lower.contains('overthinking')) {
      return "Hello, I hear you. As your **Afya Agent**, I want you to know that anxiety and worry are common physiological responses to stress, and there are proven tools to regain calm:\n\n"
          "**1. The 5-4-3-2-1 Sensory Grounding Technique:**\n"
          "Look around your room and consciously identify:\n"
          "• **5 things you can see** (e.g., a chair, a window, a cup)\n"
          "• **4 things you can touch** (e.g., your clothing, the table, your hair)\n"
          "• **3 things you can hear** (e.g., distant traffic, a fan, breathing)\n"
          "• **2 things you can smell** (e.g., soap, fresh air)\n"
          "• **1 thing you can taste** (e.g., mint, water)\n\n"
          "**2. 4-7-8 Breathing Exercise:**\n"
          "Inhale quietly through your nose for **4 seconds**, hold your breath for **7 seconds**, and exhale completely through your mouth with a whoosh sound for **8 seconds**. Repeat 4 times.\n\n"
          "**3. Thought Defusion:**\n"
          "Remind yourself: *'I am having an anxious thought, but thoughts are not facts, and this feeling will pass.'*\n\n"
          "*If anxiety is persistent, overwhelming, or interfering with daily life, consider speaking with a mental health professional or counselor.*";
    }

    if (lower.contains('stress') ||
        lower.contains('burnout') ||
        lower.contains('overwhelmed') ||
        lower.contains('exhausted') ||
        lower.contains('pressure')) {
      return "As your **Afya Agent**, here is some compassionate psychological guidance for navigating stress and burnout:\n\n"
          "**Understanding Stress:**\n"
          "Prolonged stress elevates cortisol levels, leading to tension, fatigue, mood shifts, and weakened immunity.\n\n"
          "**Evidence-Based Reset Strategies:**\n"
          "• **Micro-Breaks:** Take 5 minutes away from screens every 90 minutes. Step outside or gaze at natural light.\n"
          "• **Progressive Muscle Relaxation:** Tense your shoulders for 5 seconds, then deliberately release them. Notice the contrast.\n"
          "• **Boundary Setting:** Identify 1 non-essential task you can decline or delegate today.\n"
          "• **Physical Movement:** A brisk 15-minute walk helps metabolize accumulated stress hormones.\n\n"
          "*Remember to check in with your body throughout the day. How does your chest and breathing feel right now?*";
    }

    if (lower.contains('depress') ||
        lower.contains('sad') ||
        lower.contains('hopeless') ||
        lower.contains('empty') ||
        lower.contains('lonely') ||
        lower.contains('crying')) {
      return "I'm really glad you reached out. As your **Afya Agent**, please know that your feelings are valid, and you don't have to navigate heavy emotional periods alone.\n\n"
          "**Gentle Steps for Low Mood:**\n"
          "• **Micro-Goals (Behavioral Activation):** When motivation is low, choose tiny, manageable actions—like drinking a glass of water, making your bed, or stepping onto the balcony for fresh air.\n"
          "• **Self-Compassion:** Speak to yourself with the same kindness you would show to a dear friend who is hurting.\n"
          "• **Human Connection:** Reach out to someone you trust, even just with a brief message to say hello.\n"
          "• **Daily Light:** Spend 15-20 minutes in natural morning sunlight to support mood-regulating neurotransmitters.\n\n"
          "*Important Note: If you ever experience feelings of self-harm or deep despair, please reach out to a local crisis hotline, a trusted family member, or a licensed healthcare professional immediately. There is help and hope.*";
    }

    if (lower.contains('sleep') ||
        lower.contains('insomnia') ||
        lower.contains('tired') ||
        lower.contains('can\'t sleep')) {
      return "**Sleep & Circadian Wellness — from Afya Agent:**\n\n"
          "Healthy sleep is the foundation for cognitive function, emotional stability, and immune defense.\n\n"
          "**Psychological & Environmental Sleep Hygiene:**\n"
          "• **Consistent Schedule:** Wake up and go to sleep at the same time every day, including weekends.\n"
          "• **The 20-Minute Rule:** If you can't fall asleep after 20 minutes, get out of bed, sit in dim light, and read a physical book until sleepy. Don't stay in bed frustrated.\n"
          "• **Blue Light Wind-Down:** Avoid phones, laptops, and bright overhead lights 60 minutes before sleeping.\n"
          "• **Caffeine Cutoff:** Stop caffeine intake at least 8 hours before bed.\n\n"
          "*If insomnia persists for more than a few weeks, discuss it with your doctor to explore root causes.*";
    }

    // 5. Common Physical Symptoms & Medical Concepts
    if (lower.contains('headache') ||
        lower.contains('head pain') ||
        lower.contains('migraine')) {
      return "**Understanding Headaches — from Afya Agent:**\n\n"
          "Headaches can stem from tension, stress, dehydration, lack of sleep, eye strain, or sinus pressure.\n\n"
          "**Supportive Measures:**\n"
          "• Drink a large glass of water to rule out dehydration.\n"
          "• Rest in a quiet, darkened room with a cool or warm compress over your forehead or neck.\n"
          "• Practice slow, deep breathing to ease muscular tension.\n\n"
          "*Red Flag Alert: If your headache is sudden and extraordinarily severe ('thunderclap'), or accompanied by high fever, stiff neck, confusion, weakness, or vision changes, please seek emergency medical evaluation immediately.*";
    }

    if (lower.contains('fever') ||
        lower.contains('temperature') ||
        lower.contains('cold') ||
        lower.contains('flu') ||
        lower.contains('cough')) {
      return "**Fever & Respiratory Illness Guidance — from Afya Agent:**\n\n"
          "A fever is typically an adaptive immune mechanism indicating your body is fighting a pathogen.\n\n"
          "**Self-Care Protocol:**\n"
          "• Prioritize hydration: Water, oral rehydration solutions, warm herbal broths, or tea.\n"
          "• Rest: Avoid strenuous physical activity to conserve energy for your immune response.\n"
          "• Monitor temperature with a thermometer every 4-6 hours.\n\n"
          "*Consult a medical professional if fever exceeds 38.5°C (101.3°F), lasts over 3 days, or is accompanied by chest pain, shortness of breath, or rash.*";
    }

    if (lower.contains('blood pressure') ||
        lower.contains('vitals') ||
        lower.contains('hypertension')) {
      return "**Cardiovascular Vitals & Blood Pressure — from Afya Agent:**\n\n"
          "Maintaining healthy blood pressure is vital for long-term heart, brain, and kidney health.\n\n"
          "**Measurement Best Practices:**\n"
          "• Sit quietly with your back supported and feet flat on the floor for 5 minutes before reading.\n"
          "• Avoid caffeine, exercise, and smoking for 30 minutes beforehand.\n"
          "• Log your measurements in the Afya Vitals section so your doctor can view longitudinal trends.\n\n"
          "*Always review your vital sign targets and readings with your primary healthcare provider.*";
    }

    // 6. Default Afya Agent Greeting & Health Companion
    return "Hello! I am your **Afya Health Assistant (Afya Agent)**.\n\n"
        "I am here to support you with:\n"
        "• **Medications:** Explaining uses, schedules, side effects, adherence, and missed doses.\n"
        "• **Psychology & Emotional Well-Being:** Coping strategies for stress, anxiety, burnout, sleep, and emotional health.\n"
        "• **Medical Knowledge:** Demystifying symptoms, clinical concepts, lab tests, and preventive care.\n\n"
        "How are you feeling today? Feel free to ask any question about your health or medications.\n\n"
        "*Disclaimer: Afya AI provides educational health information and does not provide formal clinical diagnosis or prescribe treatments. Always consult your doctor for medical diagnosis.*";
  }
}
