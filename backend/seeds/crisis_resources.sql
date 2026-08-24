-- Seed data: Crisis Resources

INSERT INTO crisis_resources (label, phone, sort_order, status, created_at, updated_at) VALUES
    ('National Crisis Line', '+251911112233', 1, 'PUBLISHED', NOW(), NOW()),
    ('Nearest Emergency Hospital', '+251911223344', 2, 'PUBLISHED', NOW(), NOW()),
    ('Mental Health Hotline', '+251922334455', 3, 'PUBLISHED', NOW(), NOW()),
    ('Counseling NGO', '+251933445566', 4, 'DRAFT', NOW(), NOW())
ON CONFLICT DO NOTHING;
