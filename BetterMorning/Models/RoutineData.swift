//
//  RoutineData.swift
//  BetterMorning
//
//  Static data for celebrity morning routines.
//

import Foundation

// MARK: - Routine Type
enum RoutineType: String {
    case celebrity = "celebrity"
    case custom = "custom"
}

// MARK: - Celebrity Routine (Static Display Data)
struct CelebrityRoutine: Identifiable {
    let id: UUID
    let name: String
    let bio: String
    let imageName: String
    let tasks: [CelebrityTask]
    let type: RoutineType
    let isActive: Bool
    
    init(
        name: String,
        bio: String,
        imageName: String,
        tasks: [CelebrityTask],
        type: RoutineType = .celebrity,
        isActive: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.bio = bio
        self.imageName = imageName
        self.tasks = tasks
        self.type = type
        self.isActive = isActive
    }
}

// MARK: - Celebrity Task
struct CelebrityTask: Identifiable {
    let id: UUID
    let time: String
    let title: String
    let durationMinutes: Int
    
    init(time: String, title: String, durationMinutes: Int = 30) {
        self.id = UUID()
        self.time = time
        self.title = title
        self.durationMinutes = durationMinutes
    }
}

// MARK: - Static Celebrity Routines Data
struct RoutineData {
    
    static let celebrityRoutines: [CelebrityRoutine] = [
        
        CelebrityRoutine(
            name: "The Customer - First Morning",
            bio: "A disciplined, early-rising routine built around focus, consistency, and clear thinking. This morning emphasizes thoughtful communication, attention to real user needs, and starting the day with intention before most people are awake.",
            imageName: "avatar_17",
            tasks: [
                CelebrityTask(time: "3:45 AM", title: "Wake up early and avoid social media", durationMinutes: 5),
                CelebrityTask(time: "3:50 AM", title: "Review 5–10 important emails (customers or stakeholders)", durationMinutes: 25),
                CelebrityTask(time: "4:15 AM", title: "Write down 1 customer or user problem worth remembering", durationMinutes: 15),
                CelebrityTask(time: "4:30 AM", title: "Do 10–15 minutes of quiet reading or reflection", durationMinutes: 30),
                CelebrityTask(time: "5:00 AM", title: "Complete a gym workout or brisk movement", durationMinutes: 50),
                CelebrityTask(time: "5:50 AM", title: "Cool down, shower, and reset", durationMinutes: 10),
                CelebrityTask(time: "6:00 AM", title: "Eat a simple, repeatable breakfast", durationMinutes: 15),
                CelebrityTask(time: "6:15 AM", title: "Review top 3 priorities for the day", durationMinutes: 15),
                CelebrityTask(time: "6:30 AM", title: "Start work earlier than average", durationMinutes: 15),
                CelebrityTask(time: "6:45 AM", title: "Send one thoughtful reply before 8am", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Grounded Presence Morning",
            bio: "A calm, reflective morning centered on emotional awareness, intention, and mindful presence. This routine prioritizes slowing down, connecting inwardly, and choosing how you want to feel before the day fully begins.",
            imageName: "avatar_10",
            tasks: [
                CelebrityTask(time: "6:00 AM", title: "Wake naturally without rushing, allowing body to fully awaken", durationMinutes: 5),
                CelebrityTask(time: "6:05 AM", title: "Take three slow, grounding breaths to settle mind", durationMinutes: 5),
                CelebrityTask(time: "6:10 AM", title: "Go outside for walk, dogs, or fresh morning air", durationMinutes: 15),
                CelebrityTask(time: "6:25 AM", title: "Prepare coffee or tea mindfully, focusing on aromas", durationMinutes: 15),
                CelebrityTask(time: "6:40 AM", title: "Read or write a daily intention for clarity", durationMinutes: 10),
                CelebrityTask(time: "6:50 AM", title: "Sit in meditation or quiet reflection, observing thoughts", durationMinutes: 20),
                CelebrityTask(time: "7:10 AM", title: "Do gentle yoga or stretching to loosen body", durationMinutes: 20),
                CelebrityTask(time: "7:30 AM", title: "Choose an emotional state to embody today intentionally", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Efficiency-First Morning",
            bio: "A problem-solving focused routine designed for clarity, speed, and execution. This morning minimizes distractions, emphasizes high-leverage thinking, and channels energy into solving the most important challenge of the day.",
            imageName: "avatar_4",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake up and orient mind toward today's priorities", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Check only critical emails requiring immediate decisions today", durationMinutes: 10),
                CelebrityTask(time: "7:15 AM", title: "Identify the single most important problem to solve today", durationMinutes: 5),
                CelebrityTask(time: "7:20 AM", title: "Shower while thinking deliberately, avoiding phone scrolling entirely", durationMinutes: 20),
                CelebrityTask(time: "7:40 AM", title: "Drink coffee or water, skipping breakfast if personally preferred", durationMinutes: 5),
                CelebrityTask(time: "7:45 AM", title: "Begin a deep, uninterrupted work block with full focus", durationMinutes: 75),
                CelebrityTask(time: "9:00 AM", title: "Continue focused execution on primary objective without distractions", durationMinutes: 30),
                CelebrityTask(time: "9:30 AM", title: "Review progress against the main problem and adjust approach", durationMinutes: 15),
                CelebrityTask(time: "9:45 AM", title: "Write one technical or strategic insight you discovered", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Decisive Discipline Morning",
            bio: "A highly structured morning built on routine, precision, and consistency. This approach removes unnecessary decisions, reinforces personal standards, and creates momentum through deliberate habits and early commitment.",
            imageName: "avatar_1",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake at a fixed time, without hesitation or snoozing", durationMinutes: 45),
                CelebrityTask(time: "5:45 AM", title: "Complete physical activity like tennis or brisk morning walk", durationMinutes: 60),
                CelebrityTask(time: "6:45 AM", title: "Shower and grooming performed efficiently, deliberately, and consistently", durationMinutes: 15),
                CelebrityTask(time: "7:00 AM", title: "Get dressed in a consistent personal uniform, minimizing decisions", durationMinutes: 30),
                CelebrityTask(time: "7:30 AM", title: "Eat a light, predictable breakfast without distractions or substitutions", durationMinutes: 15),
                CelebrityTask(time: "7:45 AM", title: "Review calendar and commitments, prioritizing high-impact responsibilities", durationMinutes: 15),
                CelebrityTask(time: "8:00 AM", title: "Arrive at work early to set tone and authority", durationMinutes: 5),
                CelebrityTask(time: "8:05 AM", title: "Begin work immediately without warm-up tasks or procrastination", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Strong Foundation Morning",
            bio: "A balanced, strength-driven routine grounded in discipline, family connection, and self-care. This morning combines physical training, focused presence, and steady preparation for a demanding, meaningful day.",
            imageName: "avatar_9",
            tasks: [
                CelebrityTask(time: "4:30 AM", title: "Wake up early with calm intention and steady focus", durationMinutes: 10),
                CelebrityTask(time: "4:40 AM", title: "Hydrate body and mentally prepare for physical, focused readiness", durationMinutes: 20),
                CelebrityTask(time: "5:00 AM", title: "Complete a full, challenging workout building strength and endurance", durationMinutes: 50),
                CelebrityTask(time: "5:50 AM", title: "Cool down, stretch, and shower to reset body and mind", durationMinutes: 20),
                CelebrityTask(time: "6:10 AM", title: "Spend focused, present time with family, listening and helping", durationMinutes: 50),
                CelebrityTask(time: "7:00 AM", title: "Eat breakfast slowly, without multitasking or digital distractions", durationMinutes: 20),
                CelebrityTask(time: "7:20 AM", title: "Review daily commitments and priorities for clarity and realistic pacing", durationMinutes: 10),
                CelebrityTask(time: "7:30 AM", title: "Begin work, writing, or meetings focused with energy and confidence", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Earned Authority Morning",
            bio: "A composed leadership routine focused on clarity, responsibility, and thoughtful decision-making. This morning blends physical readiness, informed perspective, and calm preparation for high-stakes leadership work.",
            imageName: "avatar_3",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake up calmly and deliberately to center attention", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Complete weights or cardio workout to energize body", durationMinutes: 40),
                CelebrityTask(time: "7:45 AM", title: "Shower and dress with intention for confident leadership presence", durationMinutes: 15),
                CelebrityTask(time: "8:00 AM", title: "Eat breakfast with family, fully present and screen-free", durationMinutes: 30),
                CelebrityTask(time: "8:30 AM", title: "Read newspapers or leadership briefings for informed perspective", durationMinutes: 20),
                CelebrityTask(time: "8:50 AM", title: "Identify today's hardest decision requiring clarity and resolve", durationMinutes: 10),
                CelebrityTask(time: "9:00 AM", title: "Begin meetings and leadership work with focus and accountability", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Creative Spark Morning",
            bio: "An imaginative, unstructured morning designed to access creativity and subconscious ideas. This routine encourages curiosity, sensory awareness, and playful exploration before formal work begins.",
            imageName: "avatar_12",
            tasks: [
                CelebrityTask(time: "8:00 AM", title: "Wake slowly, allowing thoughts to surface naturally and unforced", durationMinutes: 5),
                CelebrityTask(time: "8:05 AM", title: "Sit quietly with eyes closed, breathing deeply and observing", durationMinutes: 5),
                CelebrityTask(time: "8:10 AM", title: "Capture one strange or abstract idea without judgment or filtering", durationMinutes: 5),
                CelebrityTask(time: "8:15 AM", title: "Drink hot water or warm beverage, noticing comfort and warmth", durationMinutes: 15),
                CelebrityTask(time: "8:30 AM", title: "Eat a simple breakfast, keeping flavors light and uncomplicated", durationMinutes: 30),
                CelebrityTask(time: "9:00 AM", title: "Take a short walk for visual inspiration and sensory input", durationMinutes: 45),
                CelebrityTask(time: "9:45 AM", title: "Review or sketch ideas, exploring unusual combinations and contrasts", durationMinutes: 15),
                CelebrityTask(time: "10:00 AM", title: "Begin creative work with curiosity, openness, and playful experimentation", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Energy-Driven Morning",
            bio: "A high-energy, optimistic routine centered on movement, connection, and idea generation. This morning favors activity, conversation, and momentum to fuel both creativity and productivity.",
            imageName: "avatar_11",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake up early and prepare for active day", durationMinutes: 10),
                CelebrityTask(time: "5:10 AM", title: "Exercise outdoors, preferably in fresh morning air", durationMinutes: 50),
                CelebrityTask(time: "6:00 AM", title: "Cool down slowly and hydrate body thoroughly afterward", durationMinutes: 15),
                CelebrityTask(time: "6:15 AM", title: "Eat breakfast with others, present and conversational together", durationMinutes: 30),
                CelebrityTask(time: "6:45 AM", title: "Scan emails briefly, avoiding deep replies or decisions", durationMinutes: 15),
                CelebrityTask(time: "7:00 AM", title: "Write down three ideas without judging quality yet", durationMinutes: 15),
                CelebrityTask(time: "7:15 AM", title: "Choose one fun or playful task to prioritize", durationMinutes: 15),
                CelebrityTask(time: "7:30 AM", title: "Start work energized, carrying momentum into the day", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The High-Quality Decision Morning",
            bio: "A slow, deliberate morning built to protect mental clarity and long-term thinking. This routine avoids early pressure, prioritizes rest and presence, and reserves energy for important decisions later in the day.",
            imageName: "avatar_6",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake after full night of restorative sleep feeling refreshed", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Spend time puttering without structured agenda or pressure today", durationMinutes: 35),
                CelebrityTask(time: "7:45 AM", title: "Eat breakfast with family, unrushed and present together", durationMinutes: 45),
                CelebrityTask(time: "8:30 AM", title: "Drink coffee slowly while conversing casually with family", durationMinutes: 60),
                CelebrityTask(time: "9:30 AM", title: "Review only high-impact priorities for today with clear intent", durationMinutes: 30),
                CelebrityTask(time: "10:00 AM", title: "Attend first meeting of the day well prepared", durationMinutes: 60),
                CelebrityTask(time: "11:00 AM", title: "Make important decisions with full clarity and long-term perspective", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The State-Change Morning",
            bio: "An energizing routine designed to rapidly shift physical and emotional state. This morning uses movement, breath, gratitude, and visualization to create focus, confidence, and elevated momentum.",
            imageName: "avatar_19",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake up and hydrate body immediately upon rising", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Take supplements according to personal protocol and timing", durationMinutes: 5),
                CelebrityTask(time: "7:10 AM", title: "Perform energizing breathwork sequence to elevate focus quickly", durationMinutes: 10),
                CelebrityTask(time: "7:20 AM", title: "Practice gratitude for several meaningful things intentionally", durationMinutes: 10),
                CelebrityTask(time: "7:30 AM", title: "Use cold exposure to shift physical and mental state", durationMinutes: 15),
                CelebrityTask(time: "7:45 AM", title: "Move body with intensity and purpose for energy", durationMinutes: 30),
                CelebrityTask(time: "8:15 AM", title: "Visualize successful outcomes for the day ahead clearly", durationMinutes: 45),
                CelebrityTask(time: "9:00 AM", title: "Begin work in empowered emotional state with confidence", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Discipline Morning",
            bio: "A strict, no-negotiation routine centered on ownership, physical challenge, and mental toughness. This morning reinforces accountability, consistency, and commitment through decisive early action.",
            imageName: "avatar_7",
            tasks: [
                CelebrityTask(time: "4:30 AM", title: "Wake immediately without negotiating with alarm or excuses", durationMinutes: 5),
                CelebrityTask(time: "4:35 AM", title: "Begin intense physical training session with disciplined effort", durationMinutes: 45),
                CelebrityTask(time: "5:20 AM", title: "Cool down and control breathing to recover effectively", durationMinutes: 10),
                CelebrityTask(time: "5:30 AM", title: "Shower quickly and efficiently to transition mentally forward", durationMinutes: 15),
                CelebrityTask(time: "5:45 AM", title: "Eat simple, functional breakfast fueling strength and focus", durationMinutes: 15),
                CelebrityTask(time: "6:00 AM", title: "Start work with full ownership mindset and discipline", durationMinutes: 90),
                CelebrityTask(time: "7:30 AM", title: "Review mission and responsibilities to align daily actions", durationMinutes: 30),
                CelebrityTask(time: "8:00 AM", title: "Train jiu-jitsu on scheduled days with intensity focus", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Extreme Structure Morning",
            bio: "An intensely scheduled routine built around early rising, physical training, and precise planning. This morning emphasizes structure, physical readiness, and disciplined execution from the very first hour.",
            imageName: "avatar_8",
            tasks: [
                CelebrityTask(time: "2:30 AM", title: "Wake extremely early with disciplined intention and unwavering commitment", durationMinutes: 5),
                CelebrityTask(time: "2:35 AM", title: "Pray or reflect quietly to center mind and purpose", durationMinutes: 25),
                CelebrityTask(time: "3:00 AM", title: "Perform light mobility and preparation to warm body safely", durationMinutes: 10),
                CelebrityTask(time: "3:10 AM", title: "Eat protein-focused breakfast to fuel energy and muscle recovery", durationMinutes: 30),
                CelebrityTask(time: "3:40 AM", title: "Complete demanding workout session pushing limits with focused intensity", durationMinutes: 80),
                CelebrityTask(time: "5:00 AM", title: "Stretch, recover, and regulate breathing to accelerate physical recovery", durationMinutes: 20),
                CelebrityTask(time: "5:20 AM", title: "Eat post-workout recovery meal supporting muscle repair and replenishment", durationMinutes: 25),
                CelebrityTask(time: "5:45 AM", title: "Review schedule and commitments to plan execution and priorities", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Balanced Performance Morning",
            bio: "A performance-oriented routine blending physical training, recovery, and personal care. This morning balances intensity with presence, supporting both athletic focus and long-term sustainability.",
            imageName: "avatar_14",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake with steady, relaxed focus and calm intentional breathing", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Eat nourishing breakfast to fuel training and sustained energy", durationMinutes: 35),
                CelebrityTask(time: "7:45 AM", title: "Warm up body with dynamic movement and mobility drills", durationMinutes: 30),
                CelebrityTask(time: "8:15 AM", title: "Complete focused training or practice session with purposeful intensity", durationMinutes: 60),
                CelebrityTask(time: "9:15 AM", title: "Stretch and prioritize recovery with breath control techniques", durationMinutes: 15),
                CelebrityTask(time: "9:30 AM", title: "Perform personal care or skincare routine attentively and consistently", durationMinutes: 15),
                CelebrityTask(time: "9:45 AM", title: "Spend quality time with family present and engaged", durationMinutes: 15),
                CelebrityTask(time: "10:00 AM", title: "Shift into business or planning work with strategic clarity", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Calm Clarity Morning",
            bio: "A gentle, restorative routine centered on sleep, mindfulness, and nervous-system regulation. This morning protects calm focus, reduces cognitive overload, and supports sustainable productivity.",
            imageName: "avatar_2",
            tasks: [
                CelebrityTask(time: "6:30 AM", title: "Wake gently without urgency or stress, easing into awareness", durationMinutes: 5),
                CelebrityTask(time: "6:35 AM", title: "Take deep breaths to calm nervous system and settle mind", durationMinutes: 10),
                CelebrityTask(time: "6:45 AM", title: "Set intention for the day ahead with clarity and purpose", durationMinutes: 15),
                CelebrityTask(time: "7:00 AM", title: "Meditate quietly without distractions, observing breath and thoughts", durationMinutes: 30),
                CelebrityTask(time: "7:30 AM", title: "Practice gentle yoga or stretching to loosen body and joints", durationMinutes: 30),
                CelebrityTask(time: "8:00 AM", title: "Eat light breakfast mindfully, savoring flavors and pacing bites", durationMinutes: 15),
                CelebrityTask(time: "8:15 AM", title: "Avoid email and digital noise to preserve morning calm", durationMinutes: 15),
                CelebrityTask(time: "8:30 AM", title: "Begin work from calm baseline with steady focus and patience", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Self-Experiment Morning",
            bio: "A reflective, systems-focused routine designed for learning and optimization. This morning emphasizes journaling, experimentation, and identifying small improvements that compound over time.",
            imageName: "avatar_18",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake and immediately make bed to signal day start", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Meditate briefly to clear mind and settle attention", durationMinutes: 15),
                CelebrityTask(time: "7:20 AM", title: "Drink tea or water slowly, noticing warmth and calm", durationMinutes: 10),
                CelebrityTask(time: "7:30 AM", title: "Journal one full reflective page without editing or censoring", durationMinutes: 20),
                CelebrityTask(time: "7:50 AM", title: "Define one win for today that truly matters", durationMinutes: 10),
                CelebrityTask(time: "8:00 AM", title: "Exercise using preferred modality to elevate energy levels", durationMinutes: 45),
                CelebrityTask(time: "8:45 AM", title: "Review habits or ongoing experiments, noting patterns and progress", durationMinutes: 15),
                CelebrityTask(time: "9:00 AM", title: "Begin focused, distraction-free work on highest leverage tasks", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Creative Protection Morning",
            bio: "An early, distraction-free routine designed to protect creative energy. This morning prioritizes uninterrupted focus, mental clarity, and securing meaningful creative output before the day fills up.",
            imageName: "avatar_5",
            tasks: [
                CelebrityTask(time: "4:00 AM", title: "Wake early to protect creative energy and mental clarity", durationMinutes: 10),
                CelebrityTask(time: "4:10 AM", title: "Exercise to fully wake body and elevate baseline energy", durationMinutes: 35),
                CelebrityTask(time: "4:45 AM", title: "Shower and transition mentally, shifting into focused creative mode", durationMinutes: 15),
                CelebrityTask(time: "5:00 AM", title: "Prepare coffee or tea deliberately, savoring aroma and warmth", durationMinutes: 10),
                CelebrityTask(time: "5:10 AM", title: "Journal thoughts and clear mental clutter before creative work begins", durationMinutes: 20),
                CelebrityTask(time: "5:30 AM", title: "Enter uninterrupted creative work block with single-minded focus", durationMinutes: 75),
                CelebrityTask(time: "6:45 AM", title: "Capture drafts and ideas quickly without overthinking or self-editing", durationMinutes: 15),
                CelebrityTask(time: "7:00 AM", title: "Transition into meetings or filming after creative output secured", durationMinutes: 15),
                CelebrityTask(time: "7:15 AM", title: "Track creative mornings completed to reinforce consistency", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Empathetic Leader Morning",
            bio: "A thoughtful leadership routine grounded in empathy, reflection, and perspective. This morning emphasizes gratitude, learning, and intentional connection before entering decision-heavy work.",
            imageName: "avatar_13",
            tasks: [
                CelebrityTask(time: "6:00 AM", title: "Wake calmly and orient toward gratitude for the day", durationMinutes: 10),
                CelebrityTask(time: "6:10 AM", title: "Reflect on things you appreciate from yesterday and today", durationMinutes: 20),
                CelebrityTask(time: "6:30 AM", title: "Run or exercise mindfully, focusing on breath and form", durationMinutes: 45),
                CelebrityTask(time: "7:15 AM", title: "Shower and reset mentally to transition into leadership mode", durationMinutes: 15),
                CelebrityTask(time: "7:30 AM", title: "Read thoughtful or reflective material to broaden perspective", durationMinutes: 20),
                CelebrityTask(time: "7:50 AM", title: "Meditate briefly to center attention before work begins", durationMinutes: 10),
                CelebrityTask(time: "8:00 AM", title: "Reach out to key people with empathy and curiosity", durationMinutes: 30),
                CelebrityTask(time: "8:30 AM", title: "Begin leadership work intentionally with clarity and purpose", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Structured Family Morning",
            bio: "A family-centered routine balancing personal preparation with caregiving responsibilities. This morning emphasizes presence, patience, and organization while smoothly transitioning into focused work.",
            imageName: "avatar_15",
            tasks: [
                CelebrityTask(time: "5:30 AM", title: "Wake early and prepare for day with calm focus", durationMinutes: 10),
                CelebrityTask(time: "5:40 AM", title: "Exercise or meditate briefly to energize body and mind", durationMinutes: 30),
                CelebrityTask(time: "6:10 AM", title: "Eat breakfast with children present, attentive and screen-free", durationMinutes: 30),
                CelebrityTask(time: "6:40 AM", title: "Help kids prepare for school calmly and efficiently together", durationMinutes: 20),
                CelebrityTask(time: "7:00 AM", title: "Complete school drop-off smoothly, staying patient and positive", durationMinutes: 20),
                CelebrityTask(time: "7:20 AM", title: "Review priorities and schedule, clarifying top tasks today", durationMinutes: 10),
                CelebrityTask(time: "7:30 AM", title: "Start workday with focus, minimizing distractions immediately intentionally", durationMinutes: 60),
                CelebrityTask(time: "8:30 AM", title: "Enter execution-heavy work block with momentum and clear objectives", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Global CEO Morning",
            bio: "An internationally aware routine designed for calm focus and strategic leadership. This morning balances personal grounding, global communication, and intentional preparation for complex responsibilities.",
            imageName: "avatar_20",
            tasks: [
                CelebrityTask(time: "5:15 AM", title: "Wake early with calm focus and steady breathing", durationMinutes: 15),
                CelebrityTask(time: "5:30 AM", title: "Prepare coffee as grounding ritual, savoring aroma and warmth", durationMinutes: 30),
                CelebrityTask(time: "6:00 AM", title: "Walk dog or step outside briefly for fresh air", durationMinutes: 30),
                CelebrityTask(time: "6:30 AM", title: "Review day lightly without stress, prioritizing essentials only", durationMinutes: 60),
                CelebrityTask(time: "7:30 AM", title: "Handle international messages and calls with clarity and empathy", durationMinutes: 45),
                CelebrityTask(time: "8:15 AM", title: "Pause and mentally reset, breathing slowly to regain balance", durationMinutes: 15),
                CelebrityTask(time: "8:30 AM", title: "Begin strategic leadership work with intention and focused energy", durationMinutes: 60),
                CelebrityTask(time: "9:30 AM", title: "Attend leadership meetings prepared, aligned on goals and context", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        CelebrityRoutine(
            name: "The Quiet Creation Morning",
            bio: "A quiet, early routine built to protect deep creative focus. This morning emphasizes solitude, writing, and uninterrupted flow before external demands and distractions take over.",
            imageName: "avatar_16",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake early before household noise and daily demands begin", durationMinutes: 15),
                CelebrityTask(time: "5:15 AM", title: "Journal quietly to clear mind and surface creative thoughts", durationMinutes: 30),
                CelebrityTask(time: "5:45 AM", title: "Drink coffee or tea slowly, savoring warmth and quiet", durationMinutes: 15),
                CelebrityTask(time: "6:00 AM", title: "Eat breakfast without distractions, staying present and nourished", durationMinutes: 30),
                CelebrityTask(time: "6:30 AM", title: "Prepare children for the day calmly and attentively together", durationMinutes: 30),
                CelebrityTask(time: "7:00 AM", title: "Begin focused writing block with clear intention and momentum", durationMinutes: 90),
                CelebrityTask(time: "8:30 AM", title: "Capture ideas and notes without interrupting creative flow", durationMinutes: 30),
                CelebrityTask(time: "9:00 AM", title: "Transition into production work smoothly, maintaining creative energy", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        )
    ]
}
