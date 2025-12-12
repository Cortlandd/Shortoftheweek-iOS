//
//  SOTWSeed.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/11/25.
//

import Foundation

enum SOTWSeed {

    static let sampleFilms: [Film] = {
        // MARK: - Article bodies

        let noVacancyContent = """
        <p>I’ve always lived a little sideways in my own mind, constantly meandering and drifting, carried from one thought to the next by the smallest spark. I never really stopped to think how everyone else’s mind worked. But Miguel Rodrick did. And in <em>No Vacancy</em>, he created a short that captures that state with startling honesty.</p>
        <p>From the first frames, the film hums with that restless mental rhythm - images slipping into one another, mutating, colliding without any warning.&nbsp;Aesthetically, it’s a beautifully disorienting swirl: messy, sometimes blurry, always wonderfully subjective shots that feel like perception dissolving into memory.</p>
        [caption id="attachment_41757" align="aligncenter" width="640"]<img class="size-large wp-image-41757" src="https://www.shortoftheweek.com/wp-content/uploads/2025/12/No-Vacancy-01-640x320.jpeg" alt="No Vacancy Short Film" width="640" height="320" /> "I wanted to make a film that felt like looking directly into someone’s mind." - Rodrick on his aims for his short.[/caption]
        <p>Watching it, I felt seen. My mind can leap from a grounded idea into a completely different universe with barely any provocation - a stray noise, a flicker of light, a fly passing by. And in an era of relentless device-induced overstimulation, those leaps grow more extreme. <em>No Vacancy</em> understands that drift intimately- it doesn’t judge it, it just invites you to come along for the ride.</p>
        """

        let helloStrangerContent = """
        <p><em>Hello Stranger</em> follows Cooper between loads of laundry at the corner laundromat.</p>
        <p>The film moves between humor and vulnerability with a light touch — short scenes, strong character, and a steady emotional build.</p>
        """

        let sunshineCityContent = """
        <p>Stellar and Max are living out of their car and trying to get back on their feet.</p>
        [caption id="attachment_41699" align="aligncenter" width="640"]<img class="size-large wp-image-41699" src="https://www.shortoftheweek.com/wp-content/uploads/2025/12/Sunshine-City-Short-Film-02-640x385.jpg" alt="Sunshine City Short Film" width="640" height="385" /> A quiet frame in between the chaos.[/caption]
        <p>Between cities, jobs, and strained conversations, they keep moving — because stopping feels like failing.</p>
        [caption id="attachment_41698" align="aligncenter" width="640"]<img class="size-large wp-image-41698" src="https://www.shortoftheweek.com/wp-content/uploads/2025/12/Sunshine-City-Short-Film-01-640x385.jpg" alt="Sunshine City Short Film" width="640" height="385" /> Another still from the film.[/caption]
        <p>If your text doesn’t wrap correctly between those two images, your parser/rendering still has a “no-break” character or a forced-width view somewhere.</p>
        """

        // MARK: - Authors

        let marianaRekka = FeedAuthor(
            displayName: "Mariana Rekka",
            firstName: "Mariana",
            lastName: "Rekka",
            id: "9001",
            company: nil,
            occupation: nil,
            email: nil
        )

        let staffAuthor = FeedAuthor(
            displayName: "Short of the Week Staff",
            firstName: nil,
            lastName: nil,
            id: "9002",
            company: nil,
            occupation: nil,
            email: nil
        )

        let guestAuthor = FeedAuthor(
            displayName: "Guest Contributor",
            firstName: nil,
            lastName: nil,
            id: "9003",
            company: nil,
            occupation: nil,
            email: nil
        )
        
        // MARK: - Country
        
        let novacancyCountry = FeedTerm(
            id: 2, color: nil, displayName: "Columbia", slug: "columbia"
        )

        // MARK: - Terms (genres etc.)

        let experimentalGenre = FeedTerm(
            id: 2,
            color: nil,
            displayName: "Experimental",
            slug: "experimental"
        )

        let documentaryGenre = FeedTerm(
            id: 3,
            color: nil,
            displayName: "Documentary",
            slug: "documentary"
        )

        let dramaGenre = FeedTerm(
            id: 4,
            color: nil,
            displayName: "Drama",
            slug: "drama"
        )

        // MARK: - Feed items (FeedItem, not custom seed structs)

        let noVacancyItem = FeedItem(
            id: 41719,
            postAuthor: "138670",
            postContentHTML: noVacancyContent,
            postDateString: "2025-12-11 10:00:00",
            postTitle: "No Vacancy",
            postName: "no-vacancy",
            backgroundImage: "//static.shortoftheweek.com/wp-content/uploads/2025/12/No-Vacancy.jpg",
            categories: nil,
            author: marianaRekka,
            country: novacancyCountry,
            filmmaker: "Miguel Rodrick",
            labels: nil,
            links: nil,
            durationString: "7",
            genre: experimentalGenre,
            playLink: "https://www.youtube.com/embed/pgCysEKt7Pc",
            playLinkTarget: "video",
            postExcerpt: "A man drifts in search of release from a past that lingers in every room.",
            production: "Miguel Rodrick",
            style: nil,
            subscriptions: nil,
            tags: nil,
            textColor: nil,
            twitterText: nil,
            thumbnail: "//static.shortoftheweek.com/wp-content/uploads/2025/12/No-Vacancy-640x320.jpg",
            type: "video",
            topic: nil
        )

        let helloStrangerItem = FeedItem(
            id: 41703,
            postAuthor: "24407",
            postContentHTML: helloStrangerContent,
            postDateString: "2025-12-10 10:00:00",
            postTitle: "Hello Stranger",
            postName: "hello-stranger",
            backgroundImage: "//static.shortoftheweek.com/wp-content/uploads/2025/12/HELLO_STRANGER_04.jpeg",
            categories: nil,
            author: staffAuthor,
            country: nil,
            filmmaker: "—",
            labels: nil,
            links: nil,
            durationString: "17",
            genre: documentaryGenre,
            playLink: "https://www.youtube.com/embed/J8tNQ21seIo",
            playLinkTarget: "video",
            postExcerpt: "Between loads of laundry at the corner laundromat, Cooper shares the tumultuous story of her gender reassignment journey.",
            production: "—",
            style: nil,
            subscriptions: nil,
            tags: nil,
            textColor: nil,
            twitterText: nil,
            thumbnail: "//static.shortoftheweek.com/wp-content/uploads/2025/12/HELLO_STRANGER_04-640x480.jpeg",
            type: "video",
            topic: nil
        )

        let sunshineCityItem = FeedItem(
            id: 41699,
            postAuthor: "55",
            postContentHTML: sunshineCityContent,
            postDateString: "2025-12-09 10:00:00",
            postTitle: "Sunshine City",
            postName: "sunshine-city",
            backgroundImage: "//static.shortoftheweek.com/wp-content/uploads/2025/12/Sunshine-City-Short-Film-02.jpg",
            categories: nil,
            author: guestAuthor,
            country: nil,
            filmmaker: "—",
            labels: nil,
            links: nil,
            durationString: "16",
            genre: dramaGenre,
            playLink: "https://player.vimeo.com/video/1144069134",
            playLinkTarget: "video",
            postExcerpt: "Siblings Stellar and Max are living out of their car and trying to get back on their feet.",
            production: "—",
            style: nil,
            subscriptions: nil,
            tags: nil,
            textColor: nil,
            twitterText: nil,
            thumbnail: "//static.shortoftheweek.com/wp-content/uploads/2025/12/Sunshine-City-Short-Film-02-640x385.jpg",
            type: "video",
            topic: nil
        )

        let items = [noVacancyItem, helloStrangerItem, sunshineCityItem]
        return items.map(Film.init(feedItem:))
    }()
}
