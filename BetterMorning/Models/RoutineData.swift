//
//  RoutineData.swift
//  BetterMorning
//
//  Static data for celebrity morning routines.
//

import Foundation

// MARK: - Routine Type
enum RoutineType {
    case celebrity
    case custom
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
        
        // MARK: - Tim Cook
        CelebrityRoutine(
            name: "Tim Cook",
            bio: "Tim Cook is the CEO of Apple, known for his disciplined lifestyle, operational brilliance, and leadership style rooted in focus and consistency. He’s recognized for early mornings, direct communication, and a relentless commitment to Apple’s global innovation.",
            imageName: "avatar_tim_cook",
            tasks: [
                CelebrityTask(time: "3:45 AM", title: "Wake Up", durationMinutes: 5),
                CelebrityTask(time: "3:50 AM", title: "Review customer/team emails", durationMinutes: 70),
                CelebrityTask(time: "5:00 AM", title: "Gym workout", durationMinutes: 60),
                CelebrityTask(time: "6:00 AM", title: "Simple breakfast", durationMinutes: 30),
                CelebrityTask(time: "6:30 AM", title: "Head into the office early", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Oprah Winfrey
        CelebrityRoutine(
            name: "Oprah Winfrey",
            bio: "Oprah Winfrey is an iconic media leader, actress, and entrepreneur known for her empathy-driven storytelling, personal growth focus, and powerful influence across television, publishing, and philanthropy.",
            imageName: "avatar_oprah_winfrey",
            tasks: [
                CelebrityTask(time: "6:00 AM", title: "Wake Up (No Alarm)", durationMinutes: 20),
                CelebrityTask(time: "6:20 AM", title: "Take dogs outside", durationMinutes: 10),
                CelebrityTask(time: "6:30 AM", title: "Espresso/coffee ritual", durationMinutes: 10),
                CelebrityTask(time: "6:40 AM", title: "Read “truth” cards", durationMinutes: 10),
                CelebrityTask(time: "6:50 AM", title: "Meditation/reflection", durationMinutes: 25),
                CelebrityTask(time: "7:15 AM", title: "Light workout or yoga", durationMinutes: 45)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Elon Musk
        CelebrityRoutine(
            name: "Elon Musk",
            bio: "Elon Musk is an engineer, entrepreneur, and founder of Tesla and SpaceX. Known for his intense work ethic and ambitious vision, he focuses heavily on problem-solving, innovation, and long-term planetary impact.",
            imageName: "avatar_elon_musk",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake Up", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Check critical emails", durationMinutes: 25),
                CelebrityTask(time: "7:30 AM", title: "Quick shower", durationMinutes: 10),
                CelebrityTask(time: "7:40 AM", title: "Coffee or skip breakfast", durationMinutes: 5),
                CelebrityTask(time: "7:45 AM", title: "Deep engineering/design work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Anna Wintour
        CelebrityRoutine(
            name: "Anna Wintour",
            bio: "Anna Wintour is one of fashion’s most influential figures, shaping global style for decades as Vogue’s longtime editor-in-chief. Known for her discipline, taste, and iconic leadership presence.",
            imageName: "avatar_anna_wintour",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake up", durationMinutes: 45),
                CelebrityTask(time: "5:45 AM", title: "Tennis", durationMinutes: 75),
                CelebrityTask(time: "7:00 AM", title: "Hair/wardrobe", durationMinutes: 30),
                CelebrityTask(time: "7:30 AM", title: "Light breakfast", durationMinutes: 30),
                CelebrityTask(time: "8:00 AM", title: "Arrive at office", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Michelle Obama
        CelebrityRoutine(
            name: "Michelle Obama",
            bio: "Michelle Obama is an attorney, author, and former First Lady known for her advocacy in health, education, and community empowerment. She’s admired for her resilience, discipline, and authenticity.",
            imageName: "avatar_michelle_obama",
            tasks: [
                CelebrityTask(time: "4:30 AM", title: "Wake up", durationMinutes: 30),
                CelebrityTask(time: "5:00 AM", title: "Gym workout", durationMinutes: 60),
                CelebrityTask(time: "6:00 AM", title: "Family time; help daughters", durationMinutes: 60),
                CelebrityTask(time: "7:00 AM", title: "Breakfast", durationMinutes: 30),
                CelebrityTask(time: "7:30 AM", title: "Begin work, writing, or meetings", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Barack Obama
        CelebrityRoutine(
            name: "Barack Obama",
            bio: "Barack Obama is the 44th President of the United States, celebrated for his leadership, communication, and calm decision-making. His disciplined mornings supported a demanding presidency.",
            imageName: "avatar_barack_obama",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake up", durationMinutes: 5),
                CelebrityTask(time: "7:05 AM", title: "Weights/cardio", durationMinutes: 55),
                CelebrityTask(time: "8:00 AM", title: "Breakfast with family", durationMinutes: 30),
                CelebrityTask(time: "8:30 AM", title: "Briefings and newspapers", durationMinutes: 30),
                CelebrityTask(time: "9:00 AM", title: "Meetings & decision-making", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Salvador Dalí
        CelebrityRoutine(
            name: "Salvador Dalí",
            bio: "Salvador Dalí was a Spanish surrealist painter known for his dreamlike imagery, eccentric personality, and technical mastery. A pioneer of surrealism, he blended subconscious exploration with theatrical creativity.",
            imageName: "avatar_salvador_dali",
            tasks: [
                CelebrityTask(time: "8:00 AM", title: "Wake up", durationMinutes: 5),
                CelebrityTask(time: "8:05 AM", title: "Hypnagogic “key and plate” micro-nap", durationMinutes: 10),
                CelebrityTask(time: "8:15 AM", title: "Drink hot water; style mustache", durationMinutes: 15),
                CelebrityTask(time: "8:30 AM", title: "Simple breakfast + coffee", durationMinutes: 30),
                CelebrityTask(time: "9:00 AM", title: "Short walk / visual inspiration", durationMinutes: 60),
                CelebrityTask(time: "10:00 AM", title: "Begin painting in the studio", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Richard Branson
        CelebrityRoutine(
            name: "Richard Branson",
            bio: "Richard Branson is a billionaire entrepreneur and adventurer known for building the Virgin empire and living a high-energy, optimistic lifestyle.",
            imageName: "avatar_richard_branson",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake up", durationMinutes: 10),
                CelebrityTask(time: "5:10 AM", title: "Exercise (tennis/running/kitesurfing)", durationMinutes: 65),
                CelebrityTask(time: "6:15 AM", title: "Breakfast with family", durationMinutes: 30),
                CelebrityTask(time: "6:45 AM", title: "Emails", durationMinutes: 30),
                CelebrityTask(time: "7:15 AM", title: "Writing ideas, planning", durationMinutes: 45)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Jeff Bezos
        CelebrityRoutine(
            name: "Jeff Bezos",
            bio: "Jeff Bezos is the founder of Amazon and Blue Origin, known for intentional decision-making, long-term thinking, and protecting his mental clarity each morning.",
            imageName: "avatar_jeff_bezos",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake up (after 8 hours sleep)", durationMinutes: 15),
                CelebrityTask(time: "7:15 AM", title: "“Puttering,” unstructured", durationMinutes: 45),
                CelebrityTask(time: "8:00 AM", title: "Coffee, breakfast with kids", durationMinutes: 120),
                CelebrityTask(time: "10:00 AM", title: "First meeting", durationMinutes: 60),
                CelebrityTask(time: "11:00 AM", title: "High-impact decisions", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Tony Robbins
        CelebrityRoutine(
            name: "Tony Robbins",
            bio: "Tony Robbins is a world-renowned motivational speaker, author, and strategist known for high-energy performance habits and mindset training frameworks.",
            imageName: "avatar_tony_robbins",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake + supplement cocktail", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Priming: breathwork, gratitude", durationMinutes: 20),
                CelebrityTask(time: "7:30 AM", title: "Cold plunge or shower", durationMinutes: 30),
                CelebrityTask(time: "8:00 AM", title: "Light exercise", durationMinutes: 60),
                CelebrityTask(time: "9:00 AM", title: "Start coaching/work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Jocko Willink
        CelebrityRoutine(
            name: "Jocko Willink",
            bio: "Jocko Willink is a former Navy SEAL commander, leadership author, and podcaster known for extreme discipline and his “4:30 a.m.” ethos.",
            imageName: "avatar_jocko_willink",
            tasks: [
                CelebrityTask(time: "4:30 AM", title: "Wake + gym workout", durationMinutes: 60),
                CelebrityTask(time: "5:30 AM", title: "Shower; simple breakfast", durationMinutes: 30),
                CelebrityTask(time: "6:00 AM", title: "Work begins", durationMinutes: 120),
                CelebrityTask(time: "8:00 AM", title: "Jiu-jitsu (some days)", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Mark Wahlberg
        CelebrityRoutine(
            name: "Mark Wahlberg",
            bio: "Mark Wahlberg is an actor, producer, and entrepreneur known for his intense fitness regimen, early mornings, and disciplined lifestyle.",
            imageName: "avatar_mark_wahlberg",
            tasks: [
                CelebrityTask(time: "2:30 AM", title: "Wake up", durationMinutes: 5),
                CelebrityTask(time: "2:35 AM", title: "Prayer", durationMinutes: 35),
                CelebrityTask(time: "3:10 AM", title: "Breakfast", durationMinutes: 30),
                CelebrityTask(time: "3:40 AM", title: "Workout #1", durationMinutes: 100),
                CelebrityTask(time: "5:20 AM", title: "Shower + post-workout meal", durationMinutes: 30)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Serena Williams
        CelebrityRoutine(
            name: "Serena Williams",
            bio: "Serena Williams is one of the greatest athletes of all time, known for her power, resilience, and entrepreneurial ventures beyond tennis.",
            imageName: "avatar_serena_williams",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake (off-season)", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Breakfast with family", durationMinutes: 35),
                CelebrityTask(time: "7:45 AM", title: "Early workout", durationMinutes: 45),
                CelebrityTask(time: "8:30 AM", title: "Skincare + daughter time", durationMinutes: 30),
                CelebrityTask(time: "9:00 AM", title: "Training or business work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Arianna Huffington
        CelebrityRoutine(
            name: "Arianna Huffington",
            bio: "Arianna Huffington is a media entrepreneur and wellness advocate known for championing sleep, recovery, and sustainable productivity.",
            imageName: "avatar_arianna_huffington",
            tasks: [
                CelebrityTask(time: "6:30 AM", title: "Wake up", durationMinutes: 30),
                CelebrityTask(time: "7:00 AM", title: "Deep breaths + intention", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Meditation", durationMinutes: 35),
                CelebrityTask(time: "7:45 AM", title: "Exercise bike + yoga", durationMinutes: 30),
                CelebrityTask(time: "8:15 AM", title: "Begin work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Tim Ferriss
        CelebrityRoutine(
            name: "Tim Ferriss",
            bio: "Tim Ferriss is an author, investor, and podcaster known for dissecting the habits of high performers and designing practical systems for improvement.",
            imageName: "avatar_tim_ferriss",
            tasks: [
                CelebrityTask(time: "7:00 AM", title: "Wake + make bed", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Meditation", durationMinutes: 20),
                CelebrityTask(time: "7:30 AM", title: "Tea/water", durationMinutes: 5),
                CelebrityTask(time: "7:35 AM", title: "Journaling", durationMinutes: 25),
                CelebrityTask(time: "8:00 AM", title: "Exercise", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Issa Rae
        CelebrityRoutine(
            name: "Issa Rae",
            bio: "Issa Rae is an actress, writer, and producer whose creative discipline and early-morning work habits helped her rise from YouTube to HBO success.",
            imageName: "avatar_issa_rae",
            tasks: [
                CelebrityTask(time: "4:00 AM", title: "Wake up", durationMinutes: 10),
                CelebrityTask(time: "4:10 AM", title: "Workout", durationMinutes: 50),
                CelebrityTask(time: "5:00 AM", title: "Coffee + journaling", durationMinutes: 30),
                CelebrityTask(time: "5:30 AM", title: "Writing/creative work", durationMinutes: 90),
                CelebrityTask(time: "7:00 AM", title: "Filming/meetings", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Satya Nadella
        CelebrityRoutine(
            name: "Satya Nadella",
            bio: "Satya Nadella is the CEO of Microsoft, known for empathetic leadership, emotional intelligence, and guiding the company through massive transformation.",
            imageName: "avatar_satya_nadella",
            tasks: [
                CelebrityTask(time: "6:00 AM", title: "Wake", durationMinutes: 60),
                CelebrityTask(time: "7:00 AM", title: "Gratitude/reflection", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Gym or run", durationMinutes: 35),
                CelebrityTask(time: "7:45 AM", title: "Read/meditate", durationMinutes: 15),
                CelebrityTask(time: "8:00 AM", title: "Begin CEO work + outreach calls", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Sheryl Sandberg
        CelebrityRoutine(
            name: "Sheryl Sandberg",
            bio: "Sheryl Sandberg is a technology executive and author known for her leadership at Meta and her advocacy for women in the workplace.",
            imageName: "avatar_sheryl_sandberg",
            tasks: [
                CelebrityTask(time: "5:30 AM", title: "Wake", durationMinutes: 30),
                CelebrityTask(time: "6:00 AM", title: "Meditation + exercise", durationMinutes: 30),
                CelebrityTask(time: "6:30 AM", title: "Breakfast with kids", durationMinutes: 30),
                CelebrityTask(time: "7:00 AM", title: "School drop-off", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Arrive at office; review priorities", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Whitney Wolfe Herd
        CelebrityRoutine(
            name: "Whitney Wolfe Herd",
            bio: "Whitney Wolfe Herd is an entrepreneur and the founder of Bumble, known for reshaping online dating with a focus on women-first design.",
            imageName: "avatar_whitney_wolfe_herd",
            tasks: [
                CelebrityTask(time: "5:15 AM", title: "Wake", durationMinutes: 105),
                CelebrityTask(time: "7:00 AM", title: "French press coffee", durationMinutes: 10),
                CelebrityTask(time: "7:10 AM", title: "Dog walk", durationMinutes: 20),
                CelebrityTask(time: "7:30 AM", title: "Emails/calls with London team", durationMinutes: 60),
                CelebrityTask(time: "8:30 AM", title: "Strategy + leadership work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        ),
        
        // MARK: - Shonda Rhimes
        CelebrityRoutine(
            name: "Shonda Rhimes",
            bio: "Shonda Rhimes is an award-winning television producer, writer, and showrunner behind Grey’s Anatomy, Scandal, and Bridgerton, known for her disciplined creativity and storytelling mastery.",
            imageName: "avatar_shonda_rhimes",
            tasks: [
                CelebrityTask(time: "5:00 AM", title: "Wake", durationMinutes: 30),
                CelebrityTask(time: "5:30 AM", title: "Journaling/quiet time", durationMinutes: 30),
                CelebrityTask(time: "6:00 AM", title: "Coffee + breakfast", durationMinutes: 30),
                CelebrityTask(time: "6:30 AM", title: "Get kids ready", durationMinutes: 30),
                CelebrityTask(time: "7:00 AM", title: "Writing/creative work", durationMinutes: 60)
            ],
            type: .celebrity,
            isActive: false
        )
    ]
}
