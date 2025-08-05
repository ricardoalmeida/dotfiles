Create this project structure:
/youtube-production-manager/
├── /docs/
│   ├── /01-ux-research/
│   ├── /02-planning/
│   ├── /03-ui-design/
│   └── /04-architecture/
├── /.agent-artifacts/
└── /app/ (Next.js app with shadcn-ui)

Do not use web search for any phase of this project.

-----------------------------------------------------

We're building a YouTube Production Manager webapp with Next.js and shadcn components.

EXACT FEATURES TO IMPLEMENT:

1. VIDEO MANAGEMENT SYSTEM:
   - Dual view: Kanban board AND Calendar view with toggle
   - Video cards show: thumbnail, title, scheduled date, status, assigned sponsor
   - Customizable status columns: Ideas, Script, Recording, Editing, Review, Published
   - Drag & drop between columns
   - Calendar shows videos on their scheduled dates
   - Quick add video button

2. SPONSORSHIP LEADS SYSTEM:
   - Dual view: Kanban board AND Calendar view with toggle
   - Lead cards show: company name, contact, deal value, status, deadline
   - Customizable status columns: New Lead, Contacted, Negotiating, Contract, Completed
   - Drag & drop between columns
   - Calendar shows leads on their deadline dates
   - Quick add lead button

3. KEY FEATURES:
   - Link sponsorships to videos (many-to-many relationship)
   - Add/edit/delete custom status columns in both systems
   - Inline editing for all fields
   - Filter by status, date range, sponsor
   - Search across all content

Phase 1 Tasks:

1. Use the ux-researcher agent to:
   - Create optimal layouts for dual-view (board/calendar) interface
   - Design card components that show all required info efficiently
   - Plan smooth transitions between views
   - Design mobile-responsive layouts
   - Save all wireframes to /youtube-production-manager/docs/01-ux-research/wireframes/
   - Document interaction patterns in /youtube-production-manager/docs/01-ux-research/interaction-patterns.md

2. Then use the sprint-prioritizer agent to:
   - Break down into these exact components:
     * VideoCard, SponsorCard
     * KanbanBoard, CalendarView
     * StatusColumn (customizable)
     * ViewToggle, FilterBar
     * QuickAddModal, LinkSponsorModal
   - Save component breakdown to /youtube-production-manager/docs/02-planning/component-breakdown.md
   - Create implementation order in /youtube-production-manager/docs/02-planning/build-order.md

Do not add or remove features. Focus only on optimal UX for these exact features.
Update /.agent-artifacts/handoff-notes.md with layout decisions.

-----------------------------------------------------

Phase 2 - UI Design for YouTube Production Manager:

Use modern, clean design with shadcn-ui components as the base.

1. Use the ui-designer agent to:
   Design these exact components using shadcn-ui:
   
   - VideoCard: Use Card component with:
     * AspectRatio for thumbnail
     * Badge for status
     * Avatar for assigned sponsor
     * Dropdown menu for actions
   
   - SponsorCard: Use Card component with:
     * Badge for deal value
     * Progress indicator for negotiation stage
     * Avatar for company logo
     * Deadline with visual urgency indicator
   
   - KanbanBoard: Use ScrollArea with:
     * Draggable columns using dnd-kit
     * Collapsible columns
     * Column action menu (rename, delete, add)
   
   - CalendarView: Use custom grid with:
     * Month/Week/Day views
     * Cards as calendar events
     * Today indicator
     * Smooth view transitions
   
   - ViewToggle: Use Tabs component styled as toggle
   - FilterBar: Use Select, DatePicker, and Search components
   
   Save all specs to /youtube-production-manager/docs/03-ui-design/component-specs.md
   Define color system: primary (YouTube red accents), neutral grays, success/warning states

2. Then use the whimsy-injector agent to add:
   - Smooth drag animations with react-spring
   - Card hover: subtle lift and shadow
   - Status change: satisfying color transition
   - Calendar navigation: smooth slide transitions
   - Success states: brief celebration animation
   - Loading states: skeleton screens with shimmer
   - Empty states: friendly illustrations
   
   Document all animations in /youtube-production-manager/docs/03-ui-design/animations.md

Use shadcn's default spacing and typography. Keep it clean and professional.
Update /.agent-artifacts/handoff-notes.md with design decisions.

-----------------------------------------------------

Phase 3 - Frontend Development:

1. Use the rapid-prototyper agent to:
   - Initialize Next.js 14 app with TypeScript in /youtube-production-manager/app/
   - Install and configure shadcn-ui
   - Set up these exact packages:
     * @dnd-kit/sortable for drag-and-drop
     * date-fns for date handling
     * zustand for state management
     * react-spring for animations

2. Then use the frontend-developer agent to implement:

   PAGES (/app/):
   - page.tsx: Dashboard with stats overview
   - videos/page.tsx: Video management with board/calendar toggle
   - sponsors/page.tsx: Sponsor management with board/calendar toggle
   
   COMPONENTS (/components/):
   - videos/VideoCard.tsx
   - videos/VideoKanbanBoard.tsx
   - videos/VideoCalendar.tsx
   - sponsors/SponsorCard.tsx
   - sponsors/SponsorKanbanBoard.tsx
   - sponsors/SponsorCalendar.tsx
   - shared/ViewToggle.tsx
   - shared/FilterBar.tsx
   - shared/StatusColumn.tsx
   - modals/QuickAddVideo.tsx
   - modals/QuickAddSponsor.tsx
   - modals/LinkSponsorModal.tsx
   
   STATE MANAGEMENT (/store/):
   - useVideoStore.ts: videos, statuses, filters
   - useSponsorStore.ts: sponsors, statuses, filters
   - useUIStore.ts: view modes, modals
   
   Implement all animations from the design phase using react-spring.

3. Then use the test-writer-fixer agent to:
   - Write tests for drag-and-drop functionality
   - Test state management
   - Test view toggling
   - Ensure responsive design works

4. Use the performance-benchmarker agent to:
   - Optimize large lists with virtualization
   - Ensure smooth drag-and-drop even with 100+ items
   - Check calendar performance with many events

Update /.agent-artifacts/handoff-notes.md with implementation notes.

-----------------------------------------------------

Phase 4 - Backend with Next.js API Routes:

1. Use the backend-architect agent to create API routes:

   VIDEO ENDPOINTS (/app/api/videos/):
   - GET /api/videos - list with filters
   - POST /api/videos - create new video
   - PATCH /api/videos/[id] - update video
   - DELETE /api/videos/[id] - delete video
   - POST /api/videos/[id]/sponsors - link sponsor
   
   SPONSOR ENDPOINTS (/app/api/sponsors/):
   - GET /api/sponsors - list with filters
   - POST /api/sponsors - create new sponsor
   - PATCH /api/sponsors/[id] - update sponsor
   - DELETE /api/sponsors/[id] - delete sponsor
   
   STATUS ENDPOINTS (/app/api/statuses/):
   - GET /api/statuses - get all custom statuses
   - POST /api/statuses - create new status
   - PATCH /api/statuses/[id] - update status
   - DELETE /api/statuses/[id] - delete status
   
   Use in-memory storage for now with this structure:
   ```typescript
   // /app/api/db.ts
   export const db = {
     videos: [],
     sponsors: [],
     videoStatuses: ['Ideas', 'Script', 'Recording', 'Editing', 'Review', 'Published'],
     sponsorStatuses: ['New Lead', 'Contacted', 'Negotiating', 'Contract', 'Completed'],
     videoSponsorLinks: []
   }


   -----------------------------------------------------


ADDITIONAL STEPS 

Then use the api-tester agent to:

Test all CRUD operations
Test filtering and sorting
Verify drag-and-drop updates work
Test concurrent updates


Use the devops-automator agent to:

Set up Vercel deployment config
Create demo data seeding script
Set up environment variables structure
Document API in /youtube-production-manager/docs/04-architecture/api-docs.md



Update /.agent-artifacts/handoff-notes.md with API documentation.

## 🚀 Final Launch Prompt
Use the project-shipper agent to:

Ensure all features work: video management, sponsor management, linking, custom statuses
Verify drag-and-drop is smooth
Check calendar views work properly
Test on mobile devices
Create a demo video showing all features
Deploy to Vercel with demo data


These prompts define exactly what to build, leaving only the optimal positioning and user flow decisions to the UX agent. The features are locked in, but how they're arranged for the best user experience is what the UX agent determines.

