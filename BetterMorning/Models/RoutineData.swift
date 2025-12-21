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
    let title: String
    let theme: String
    let bio: String
    let imageName: String
    let tasks: [CelebrityTask]
    let type: RoutineType
    let isActive: Bool
    
    init(
        name: String,
        title: String,
        theme: String,
        bio: String,
        imageName: String,
        tasks: [CelebrityTask],
        type: RoutineType = .celebrity,
        isActive: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.title = title
        self.theme = theme
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
        
        // MARK: - Tim Cook
        CelebrityRoutine(
            name: "Tim Cook",
            title: "CEO, Apple",
            theme: "The Customer-First Morning",
            bio: "Tim Cook is the CEO of Apple, known for his disciplined lifestyle, operational brilliance, and leadership style rooted in focus and consistency. He's recognized for early mornings, direct communication, and a relentless commitment to Apple's global innovation.",
            imageName: "avatar_tim_cook",
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
        
        // MARK: - Oprah Winfrey
        CelebrityRoutine(
            name: "Oprah Winfrey",
            title: "Media mogul",
            theme: "The Grounded Presence Morning",
            bio: "Oprah Winfrey is an iconic media leader, actress, and entrepreneur known for her empathy-driven storytelling, personal growth focus, and powerful influence across television, publishing, and philanthropy.",
            imageName: "avatar_oprah_winfrey",
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
        
        // MARK: - Elon Musk
        CelebrityRoutine(
            name: "Elon Musk",
            title: "CEO, Tesla/SpaceX",
            theme: "The Efficiency-First Morning",
            bio: "Elon Musk is an engineer, entrepreneur, and founder of Tesla and SpaceX. Known for his intense work ethic and ambitious vision, he focuses heavily on problem-solving, innovation, and long-term planetary impact.",
            imageName: "avatar_elon_musk",
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
        
        // MARK: - Anna Wintour
        CelebrityRoutine(
            name: "Anna Wintour",
            title: "Former Editor-in-Chief, Vogue",
            theme: "The Decisive Discipline Morning",
            bio: "Anna Wintour is one of fashion's most influential figures, shaping global style for decades as Vogue's longtime editor-in-chief. Known for her discipline, taste, and iconic leadership presence.",
            imageName: "avatar_anna_wintour",
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
        
        // MARK: - Michelle Obama
        CelebrityRoutine(
            name: "Michelle Obama",
            title: "Former First Lady, author",
            theme: "The Strong Foundation Morning",
            bio: "Michelle Obama is an attorney, author, and former First Lady known for her advocacy in health, education, and community empowerment. She's admired for her resilience, discipline, and authenticity.",
            imageName: "avatar_michelle_obama",
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
        
        // MARK: - Barack Obama
        CelebrityRoutine(
            name: "Barack Obama",
            title: "Former U.S. President",
            theme: "The Earned Authority Morning",
            bio: "Barack Obama is the 44th President of the United States, celebrated for his leadership, communication, and calm decision-making. His disciplined mornings supported a demanding presidency.",
            imageName: "avatar_barack_obama",
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
        
        // MARK: - Salvador Dalí
        CelebrityRoutine(
            name: "Salvador Dalí",
            title: "Painter",
            theme: "The Creative Spark Morning",
            bio: "Salvador Dalí was a Spanish surrealist painter known for his dreamlike imagery, eccentric personality, and technical mastery. A pioneer of surrealism, he blended subconscious exploration with theatrical creativity.",
            imageName: "avatar_salvador_dali",
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
        
        // MARK: - Richard Branson
        CelebrityRoutine(
            name: "Richard Branson",
            title: "Founder, Virgin Group",
            theme: "The Energy-Driven Morning",
            bio: "Richard Branson is a billionaire entrepreneur and adventurer known for building the Virgin empire and living a high-energy, optimistic lifestyle.",
            imageName: "avatar_richard_branson",
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
        
        // MARK: - Jeff Bezos
        CelebrityRoutine(
            name: "Jeff Bezos",
            title: "Founder, Amazon",
            theme: "The High-Quality Decision Morning",
            bio: "Jeff Bezos is the founder of Amazon and Blue Origin, known for intentional decision-making, long-term thinking, and protecting his mental clarity each morning.",
            imageName: "avatar_jeff_bezos",
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
        
        // MARK: - Tony Robbins
        CelebrityRoutine(
            name: "Tony Robbins",
            title: "Entrepreneur & coach",
            theme: "The State-Change Morning",
            bio: "Tony Robbins is a world-renowned motivational speaker, author, and strategist known for high-energy performance habits and mindset training frameworks.",
            imageName: "avatar_tony_robbins",
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
        
        // MARK: - Jocko Willink
        CelebrityRoutine(
            name: "Jocko Willink",
            title: "Retired Navy SEAL, author",
            theme: "The Discipline Morning",
            bio: "Jocko Willink is a former Navy SEAL commander, leadership author, and podcaster known for extreme discipline and his \"4:30 a.m.\" ethos.",
            imageName: "avatar_jocko_willink",
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
        
        // MARK: - Mark Wahlberg
        CelebrityRoutine(
            name: "Mark Wahlberg",
            title: "Actor & producer",
            theme: "The Extreme Structure Morning",
            bio: "Mark Wahlberg is an actor, producer, and entrepreneur known for his intense fitness regimen, early mornings, and disciplined lifestyle.",
            imageName: "avatar_mark_wahlberg",
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
        
        // MARK: - Serena Williams
        CelebrityRoutine(
            name: "Serena Williams",
            title: "Tennis legend & entrepreneur",
            theme: "The Balanced Performance Morning",
            bio: "Serena Williams is one of the greatest athletes of all time, known for her power, resilience, and entrepreneurial ventures beyond tennis.",
            imageName: "avatar_serena_williams",
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
        
        // MARK: - Arianna Huffington
        CelebrityRoutine(
            name: "Arianna Huffington",
            title: "Founder, HuffPost & Thrive Global",
            theme: "The Calm Clarity Morning",
            bio: "Arianna Huffington is a media entrepreneur and wellness advocate known for championing sleep, recovery, and sustainable productivity.",
            imageName: "avatar_arianna_huffington",
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
        
        // MARK: - Tim Ferriss
        CelebrityRoutine(
            name: "Tim Ferriss",
            title: "Author, investor",
            theme: "The Self-Experiment Morning",
            bio: "Tim Ferriss is an author, investor, and podcaster known for dissecting the habits of high performers and designing practical systems for improvement.",
            imageName: "avatar_tim_ferriss",
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
        
        // MARK: - Issa Rae
        CelebrityRoutine(
            name: "Issa Rae",
            title: "Creator of Insecure",
            theme: "The Creative Protection Morning",
            bio: "Issa Rae is an actress, writer, and producer whose creative discipline and early-morning work habits helped her rise from YouTube to HBO success.",
            imageName: "avatar_issa_rae",
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
        
        // MARK: - Satya Nadella
        CelebrityRoutine(
            name: "Satya Nadella",
            title: "CEO, Microsoft",
            theme: "The Empathetic Leader Morning",
            bio: "Satya Nadella is the CEO of Microsoft, known for empathetic leadership, emotional intelligence, and guiding the company through massive transformation.",
            imageName: "avatar_satya_nadella",
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
        
        // MARK: - Sheryl Sandberg
        CelebrityRoutine(
            name: "Sheryl Sandberg",
            title: "Former COO, Meta",
            theme: "The Structured Family Morning",
            bio: "Sheryl Sandberg is a technology executive and author known for her leadership at Meta and her advocacy for women in the workplace.",
            imageName: "avatar_sheryl_sandberg",
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
        
        // MARK: - Whitney Wolfe Herd
        CelebrityRoutine(
            name: "Whitney Wolfe Herd",
            title: "Founder, Bumble",
            theme: "The Global CEO Morning",
            bio: "Whitney Wolfe Herd is an entrepreneur and the founder of Bumble, known for reshaping online dating with a focus on women-first design.",
            imageName: "avatar_whitney_wolfe_herd",
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
        
        // MARK: - Shonda Rhimes
        CelebrityRoutine(
            name: "Shonda Rhimes",
            title: "Showrunner, Grey's Anatomy, Scandal",
            theme: "The Quiet Creation Morning",
            bio: "Shonda Rhimes is an award-winning television producer, writer, and showrunner behind Grey's Anatomy, Scandal, and Bridgerton, known for her disciplined creativity and storytelling mastery.",
            imageName: "avatar_shonda_rhimes",
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
