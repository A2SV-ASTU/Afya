-- Seed data: Exercises & Steps
-- Box Breathing exercise with 4 steps

INSERT INTO exercises (id, slug, title, description, language, status, created_at, updated_at)
VALUES (
    'exr_box_breathing',
    'box-breathing',
    'Box Breathing',
    'A 4-step breathing pattern to calm the nervous system.',
    'en',
    'PUBLISHED',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_steps (id, exercise_id, step_type, title, instruction, duration_seconds, sort_order) VALUES
    ('stp_01', 'exr_box_breathing', 'TASK', 'Inhale', 'Breathe in slowly through your nose.', 4, 1),
    ('stp_02', 'exr_box_breathing', 'BREAK', 'Hold', NULL, 4, 2),
    ('stp_03', 'exr_box_breathing', 'TASK', 'Exhale', 'Breathe out slowly through your mouth.', 4, 3),
    ('stp_04', 'exr_box_breathing', 'BREAK', 'Hold', NULL, 4, 4)
ON CONFLICT (id) DO NOTHING;

-- 5-4-3-2-1 Grounding exercise

INSERT INTO exercises (id, slug, title, description, language, status, created_at, updated_at)
VALUES (
    'exr_grounding',
    '5-4-3-2-1-grounding',
    '5-4-3-2-1 Grounding',
    'A sensory awareness exercise to ground yourself in the present moment.',
    'en',
    'PUBLISHED',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_steps (id, exercise_id, step_type, title, instruction, duration_seconds, sort_order) VALUES
    ('stp_g01', 'exr_grounding', 'TASK', '5 Things You See', 'Look around and name 5 things you can see.', 30, 1),
    ('stp_g02', 'exr_grounding', 'TASK', '4 Things You Touch', 'Notice 4 things you can physically feel.', 30, 2),
    ('stp_g03', 'exr_grounding', 'TASK', '3 Things You Hear', 'Listen for 3 distinct sounds around you.', 20, 3),
    ('stp_g04', 'exr_grounding', 'TASK', '2 Things You Smell', 'Identify 2 things you can smell.', 15, 4),
    ('stp_g05', 'exr_grounding', 'TASK', '1 Thing You Taste', 'Notice 1 thing you can taste.', 10, 5)
ON CONFLICT (id) DO NOTHING;

-- Progressive Muscle Relaxation (DRAFT — admin only)

INSERT INTO exercises (id, slug, title, description, language, status, created_at, updated_at)
VALUES (
    'exr_pmr',
    'progressive-muscle-relaxation',
    'Progressive Muscle Relaxation',
    'Systematically tense and release muscle groups to reduce physical tension.',
    'en',
    'DRAFT',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;
