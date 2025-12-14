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

        let oscarContendersNewsContent = #"""
        <p><strong>This is the third of our series covering the Oscar® 2026 race.</strong> Each week before the shortlist voting commences on December 8th we preview a short film category and its eligible films. Previously, we covered <a href="https://www.shortoftheweek.com/news/surveying-oscar-2026-contenders-animated-short-subject/">Animated Shorts</a> and <a href="https://www.shortoftheweek.com/news/surveying-the-oscar-2026-contenders-documentary-short-film/">Documentary Shorts</a>.</p>

        <p>At last, Live Action. The category has been a punching bag for me in recent years, as it has been the site of some of the Academy’s most head-scratching decisions. If I’m being grumpy, I peruse this <a href="https://www.shortverse.com/collections/oscarr-2026-contenders-live-action-short-subject?page=1&sort=view_count_desc">enormous 207-film longlist</a> and see numerous examples of cliché premises from relatively unheralded sources.</p>

        <p>I don’t have inside knowledge of how things have changed in recent years. But it seems the ever-expanding lineup of qualifying festivals has produced a contender pool that is <em>extremely</em> culturally and geographically diverse (which rocks), but also lets a lot of marginal work through.</p>

        <p>Why should we care? Absent the institutional influence that Documentary and Animation possess, this overstuffed free-for-all benefits deep-pocketed campaigns and muddies the waters.</p>

        <p>This is an exciting and optimistic time, though, so I am sheepish about beginning this preview with complaints. Overstuffed as it is, there are many great shorts here.</p>

        <div class="mceTemp">
          <a href="https://www.shortverse.com/collections/oscarr-2026-contenders-live-action-short-subject?page=1&sort=view_count_desc">
            <img src="https://www.shortoftheweek.com/wp-content/uploads/2025/12/Live-Action-640x637.jpg" />
          </a>
        </div>

        <h3 style="text-align:center;">Meet The Online Films</h3>

        <p>Respecting our founding mission, let’s begin by introducing films you can watch right now. As of publishing, <a href="https://www.shortverse.com/collections/oscarr-2026-contenders-live-action-short-subject?page=1&release_status=50">20 films are available for streaming</a>.</p>

        <ul>
          <li><em><a href="https://www.shortoftheweek.com/2025/04/14/beyond-failure/">Beyond Failure</a></em> – An unapologetically indie short with relentless deadpan humor.</li>
          <li><em><a href="https://www.shortoftheweek.com/2025/01/16/border-hopper/">Border Hopper</a></em> – A Sundance hit tackling the US immigration system.</li>
          <li><em><a href="https://www.shortoftheweek.com/2025/11/18/daly-city/">Daly City</a></em> – A sensitive story about belonging.</li>
          <li><em><a href="https://www.shortoftheweek.com/2025/11/22/two-people-exchanging-saliva/">Deux personnes échangeant de la salive</a></em> – A dystopian absurdist triumph.</li>
          <li><em><a href="https://www.shortoftheweek.com/2025/11/05/single-residence-occupancy/">Single Residence Occupancy</a></em> – A deeply moving family drama.</li>
          <li><em><a href="https://www.shortoftheweek.com/2025/12/05/susana/">SUSANA</a></em> – An open-hearted travel film.</li>
        </ul>

        <h3 style="text-align:center;">Festival Darlings</h3>

        <p>A spotlight on films we really like that have had stellar runs on the fest circuit.</p>

        <ul>
          <li><em><a href="https://www.shortverse.com/films/amarela">Amarela</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/im-glad-youre-dead-now">I'm Glad You're Dead Now</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/one-day-this-kid">One Day This Kid</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/talk-me">Talk Me</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/vox-humana">Vox Humana</a></em></li>
        </ul>

        <h3 style="text-align:center;">Based on a True Story</h3>

        <ul>
          <li><em><a href="https://www.shortverse.com/films/extremist">Extremist</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/flight-182">Flight 182</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/jeffrey-epstein-bad-pedophile">Jeffrey Epstein: Bad Pedophile</a></em></li>
          <li><em><a href="https://www.shortverse.com/films/rock-paper-scissors">Rock Paper Scissors</a></em></li>
        </ul>

        <p style="text-align:center;">***</p>

        <p>Thanks for following our lengthy previews of the three categories. Good luck to all the qualified films as voting begins!</p>
        """#



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
        
        let jasonSondhi = FeedAuthor(
            displayName: "Jason Sondhi",
            firstName: "Jason",
            lastName: "Sondhi",
            id: "3",
            company: "Short of the Week LLC",
            occupation: nil,
            email: "sondhi@shortoftheweek.com"
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

        // MARK: - Category
        
        let oscarCoverageCategory = FeedTerm(
            id: 1354,
            color: "#DB3377",
            displayName: "Oscar Coverage",
            slug: "oscar-coverage"
        )

        let oscarCoverageCategories = FeedTermCollection(
            count: 1,
            limit: 10,
            page: 1,
            total: 0,
            pageMax: 0,
            links: nil,
            data: [oscarCoverageCategory]
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
        
        let oscarContendersNewsItem = FeedItem(
            id: 41710,
            postAuthor: "3",
            postContentHTML: oscarContendersNewsContent,
            postDateString: "2025-12-07 10:00:00",
            postTitle: "Surveying the Oscar 2026 Contenders: Live Action Short Film",
            postName: "surveying-oscar-2026-contenders-live-action-short-film",
            backgroundImage: "//static.shortoftheweek.com/wp-content/uploads/2025/04/Beyond-Failure-Marissa-Losoya-03.jpeg",
            categories: oscarCoverageCategories,
            author: jasonSondhi,
            country: nil,
            filmmaker: nil,
            labels: nil,
            links: nil,
            durationString: nil,
            genre: nil,
            playLink: nil,
            playLinkTarget: nil,
            postExcerpt: "The third of our series covering the Oscar® 2026 race.",
            production: nil,
            style: nil,
            subscriptions: nil,
            tags: nil,
            textColor: "light",
            twitterText: nil,
            thumbnail: "//static.shortoftheweek.com/wp-content/uploads/2025/04/Beyond-Failure-Marissa-Losoya-03-640x346.jpeg",
            type: "news",
            topic: nil
        )


        let items = [noVacancyItem, helloStrangerItem, sunshineCityItem, oscarContendersNewsItem]
        return items.map(Film.init(feedItem:))
    }()
}
