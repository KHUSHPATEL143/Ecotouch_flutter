# Production Dashboard Overview - Design Documentation

> **Project ID**: 13407358775887533421  
> **Platform**: Desktop Application  
> **Design Tool**: Google Stitch  
> **Last Updated**: January 31, 2026

---

## Table of Contents

1. [Design System](#design-system)
2. [Component Library](#component-library)
3. [Screen Specifications](#screen-specifications)
4. [Navigation & User Flows](#navigation--user-flows)
5. [Visual References](#visual-references)

---

## Design System

### Color Palette

The Production Dashboard uses a **Dark Mode** color scheme with a professional, industrial aesthetic.

#### Primary Colors
- **Primary Blue**: `#1975d2` (Custom brand color)
- **Saturation Level**: 3 (Enhanced color vibrancy)

#### Color Mode
- **Theme**: Dark Mode
- **Background**: Deep dark tones for reduced eye strain
- **Surface**: Elevated surfaces with subtle contrast
- **Text**: High contrast white/light gray for readability

### Typography

**Font Family**: [Inter](https://fonts.google.com/specimen/Inter)

- **Characteristics**: Modern, clean, highly legible sans-serif
- **Usage**: System-wide for all text elements
- **Weights**: Regular (400), Medium (500), Semibold (600), Bold (700)

#### Type Scale
```
Heading 1: 32px / 2rem - Bold
Heading 2: 24px / 1.5rem - Semibold
Heading 3: 20px / 1.25rem - Semibold
Body Large: 16px / 1rem - Regular
Body: 14px / 0.875rem - Regular
Caption: 12px / 0.75rem - Regular
```

### Spacing & Layout

**Grid System**: 8px base unit

```
xs: 4px   (0.5 units)
sm: 8px   (1 unit)
md: 16px  (2 units)
lg: 24px  (3 units)
xl: 32px  (4 units)
2xl: 48px (6 units)
```

### Border Radius

**Roundness**: `ROUND_FOUR` (4px)

- **Cards**: 4px
- **Buttons**: 4px
- **Input Fields**: 4px
- **Modals**: 4px

### Elevation & Shadows

```css
/* Card Shadow */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);

/* Elevated Card */
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);

/* Modal Shadow */
box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
```

---

## Component Library

### Navigation Components

#### Sidebar Navigation
- **Width**: 240px (collapsed: 64px)
- **Position**: Fixed left
- **Background**: Dark surface
- **Items**: Icon + Label (collapsible)
- **Active State**: Primary blue highlight

#### Top Bar
- **Height**: 64px
- **Content**: Breadcrumbs, Search, User Profile, Notifications
- **Background**: Dark surface with bottom border

### Data Display Components

#### Data Table
- **Header**: Sticky, bold text, sortable columns
- **Rows**: Alternating subtle background for readability
- **Actions**: Inline edit, delete, view icons
- **Pagination**: Bottom-aligned, shows total records
- **Features**: Search, filter, sort, export

#### Stat Cards
- **Layout**: Grid-based (2-4 columns)
- **Content**: Icon, Label, Value, Trend indicator
- **Size**: Flexible width, 120px min height
- **Hover**: Subtle elevation increase

#### Charts & Graphs
- **Types**: Line charts, bar charts, pie charts, area charts
- **Colors**: Primary blue with gradient variations
- **Grid**: Subtle grid lines for readability
- **Tooltips**: On hover with detailed information

### Form Components

#### Input Fields
- **Height**: 40px
- **Border**: 1px solid with focus state
- **Padding**: 12px horizontal
- **Label**: Above input, 12px margin
- **Error State**: Red border + error message below

#### Buttons
- **Primary**: Blue background, white text
- **Secondary**: Transparent with blue border
- **Danger**: Red background, white text
- **Sizes**: Small (32px), Medium (40px), Large (48px)

#### Dropdowns
- **Height**: 40px
- **Icon**: Chevron down
- **Menu**: Elevated with shadow
- **Max Height**: 300px with scroll

#### Date Picker
- **Format**: DD/MM/YYYY
- **Calendar**: Modal overlay
- **Range Selection**: Supported for reports

### Feedback Components

#### Modals
- **Backdrop**: Semi-transparent dark overlay
- **Width**: 480px (small), 720px (medium), 960px (large)
- **Header**: Title + Close button
- **Footer**: Action buttons (right-aligned)

#### Toast Notifications
- **Position**: Top-right
- **Duration**: 3-5 seconds
- **Types**: Success (green), Error (red), Warning (yellow), Info (blue)

#### Loading States
- **Spinner**: Circular, primary blue
- **Skeleton**: Animated placeholder for content
- **Progress Bar**: Linear indicator for long operations

---

## Screen Specifications

### 1. Production Dashboard Overview
**Screen ID**: `5200b927510d40898a987849079e9913`  
**Dimensions**: 2560 × 2048px

**Purpose**: Main landing page providing high-level production metrics and KPIs

**Layout**:
- Top stat cards (4 columns): Total Production, Active Orders, Inventory Status, Worker Attendance
- Charts section: Production trends, efficiency metrics
- Recent activities table
- Quick action buttons

**Key Features**:
- Real-time data updates
- Date range selector
- Export to PDF/Excel
- Drill-down navigation to detailed screens

---

### 2. Inventory & Stock Levels
**Screen ID**: `e304267bf26042808bf0bb0ab1f8828d`  
**Dimensions**: 2560 × 2048px

**Purpose**: Monitor and manage raw materials and finished goods inventory

**Layout**:
- Stock summary cards (Raw Materials, Finished Goods, In-Process)
- Inventory table with search and filters
- Low stock alerts section
- Stock movement history

**Key Features**:
- Real-time stock levels
- Low stock threshold alerts
- Stock adjustment actions
- Export inventory reports

---

### 3. Daily Worker Attendance
**Screen ID**: `27655cc2ac5c4affa8fb4bb3fe1d8714`  
**Dimensions**: 2560 × 2048px

**Purpose**: Track and manage daily worker attendance and work hours

**Layout**:
- Date selector (calendar view)
- Attendance summary (Present, Absent, Late, Leave)
- Worker list with check-in/check-out times
- Attendance marking interface

**Key Features**:
- Quick attendance marking
- Bulk actions (mark all present)
- Attendance history view
- Export attendance reports

---

### 4. Raw Material Inward Entry
**Screen ID**: `0286e5cc5ea54788bdcd1189c1115adc`  
**Dimensions**: 2560 × 2048px

**Purpose**: Record incoming raw material shipments

**Layout**:
- Entry form (Material, Supplier, Quantity, Date, Invoice)
- Recent entries table
- Supplier selection dropdown
- Material category filters

**Key Features**:
- Auto-populate from purchase orders
- Barcode/QR scanning support
- Quality check status
- Generate GRN (Goods Receipt Note)

---

### 5. Product Outward Sales
**Screen ID**: `389012c3cd71402894d7273e17e59fac`  
**Dimensions**: 2560 × 2048px

**Purpose**: Process and track finished goods sales and shipments

**Layout**:
- Sales order form
- Product selection with stock availability
- Customer information
- Delivery details

**Key Features**:
- Stock availability check
- Invoice generation
- Delivery challan creation
- Payment status tracking

---

### 6. Production Entry & Tracking
**Screen ID**: `2d16a9c7dfb148a5bf7e0704fc03ca40`  
**Dimensions**: 2560 × 2048px

**Purpose**: Record daily production output and track production jobs

**Layout**:
- Production entry form (Product, Quantity, Date, Shift)
- Active production jobs
- Machine allocation
- Quality metrics

**Key Features**:
- Multi-product entry
- Shift-wise tracking
- Defect recording
- Production efficiency calculation

---

### 7. Periodic Production Summary
**Screen ID**: `b24a6d61fa944c258d34af4079439f5b`  
**Dimensions**: 2560 × 2048px

**Purpose**: View aggregated production reports over time periods

**Layout**:
- Date range selector (Daily, Weekly, Monthly, Custom)
- Production summary charts
- Product-wise breakdown table
- Efficiency metrics

**Key Features**:
- Comparative analysis (vs previous period)
- Export to Excel/PDF
- Trend visualization
- Drill-down to daily details

---

### 8. Login & Database Selection
**Screen ID**: `0f17b9263a314ca9bbb559383b947559`  
**Dimensions**: 2560 × 2048px

**Purpose**: User authentication and database/company selection

**Layout**:
- Centered login card
- Username/password fields
- Database dropdown (for multi-company setup)
- Remember me checkbox
- Forgot password link

**Key Features**:
- Secure authentication
- Multi-database support
- Session management
- Password recovery

---

### 9. System Settings & Master Data
**Screen ID**: `6ec58d903c3045279aefcf457e798798`  
**Dimensions**: 2560 × 2048px

**Purpose**: Configure system settings and manage master data

**Layout**:
- Tabbed interface (Products, Suppliers, Customers, Workers, Machines)
- CRUD operations for each entity
- Settings panel (Company info, Preferences, Backup)

**Key Features**:
- Master data management
- User role configuration
- System preferences
- Data import/export

---

### Additional Screens

The project includes 6 more screens covering:
- **Logistics & Dispatch Management**
- **Quality Control & Inspection**
- **Machine Maintenance Tracking**
- **Financial Reports & Analytics**
- **User Management & Permissions**
- **Notifications & Alerts Center**

---

## Navigation & User Flows

### Primary Navigation Structure

```
├── Dashboard (Home)
├── Inventory
│   ├── Stock Levels
│   ├── Raw Material Inward
│   └── Product Outward
├── Production
│   ├── Production Entry
│   ├── Production Summary
│   └── Quality Control
├── Attendance
│   ├── Daily Attendance
│   └── Attendance Reports
├── Logistics
│   ├── Dispatch Management
│   └── Vehicle Tracking
├── Reports
│   ├── Production Reports
│   ├── Inventory Reports
│   └── Financial Reports
└── Settings
    ├── Master Data
    ├── User Management
    └── System Settings
```

### Key User Flows

#### Flow 1: Record Raw Material Receipt
1. Navigate to **Inventory > Raw Material Inward**
2. Click "New Entry" button
3. Select supplier from dropdown
4. Select material and enter quantity
5. Upload invoice (optional)
6. Submit entry
7. System updates inventory levels
8. Generate GRN

#### Flow 2: Mark Daily Attendance
1. Navigate to **Attendance > Daily Attendance**
2. Select date (defaults to today)
3. View worker list
4. Mark attendance status for each worker
5. Enter check-in/check-out times
6. Save attendance
7. View summary statistics

#### Flow 3: Record Production Output
1. Navigate to **Production > Production Entry**
2. Select product from dropdown
3. Enter quantity produced
4. Select shift and date
5. Assign machine/worker
6. Record any defects
7. Submit entry
8. System updates inventory and production metrics

#### Flow 4: View Production Reports
1. Navigate to **Reports > Production Reports**
2. Select date range
3. Choose report type (Summary, Detailed, Product-wise)
4. Apply filters (product, shift, machine)
5. View charts and tables
6. Export to Excel/PDF

---

## Visual References

### Design Theme Summary

| Property | Value |
|----------|-------|
| **Color Mode** | Dark |
| **Primary Color** | #1975d2 |
| **Font** | Inter |
| **Roundness** | 4px |
| **Saturation** | 3 (High) |
| **Device Type** | Desktop |
| **Screen Resolution** | 2560 × 2048px |

### Design Principles

1. **Clarity**: Clear visual hierarchy with consistent spacing
2. **Efficiency**: Quick access to frequently used features
3. **Consistency**: Unified design language across all screens
4. **Accessibility**: High contrast for readability in industrial environments
5. **Responsiveness**: Optimized for desktop workflows

### Color Usage Guidelines

- **Primary Blue (#1975d2)**: CTAs, links, active states, key metrics
- **Success Green**: Positive indicators, completed tasks
- **Warning Yellow**: Alerts, low stock warnings
- **Error Red**: Errors, critical alerts, delete actions
- **Neutral Grays**: Text, borders, backgrounds

### Iconography

- **Style**: Outlined icons for consistency
- **Size**: 20px (small), 24px (medium), 32px (large)
- **Color**: Inherits from parent or uses neutral gray
- **Library**: Material Design Icons or similar

---

## Implementation Notes

### Technology Recommendations

Based on the Stitch design, recommended tech stack:

- **Frontend Framework**: React or Vue.js
- **UI Library**: Material-UI or Ant Design (customized for dark theme)
- **Charts**: Chart.js or Recharts
- **State Management**: Redux or Vuex
- **Data Grid**: AG-Grid or React Table
- **Date Picker**: react-datepicker or similar

### Responsive Considerations

While designed for desktop (2560 × 2048px), consider:

- **Minimum Width**: 1280px
- **Tablet Support**: Simplified layout for 768px-1024px
- **Mobile**: Separate mobile-optimized views for critical functions

### Performance Optimization

- Lazy load charts and heavy components
- Implement virtual scrolling for large tables
- Cache frequently accessed data
- Optimize image assets
- Use skeleton loaders for better perceived performance

---

## Appendix

### Screen Index

| # | Screen Name | Screen ID | Purpose |
|---|-------------|-----------|---------|
| 1 | Production Dashboard Overview | 5200b927510d40898a987849079e9913 | Main dashboard |
| 2 | Inventory & Stock Levels | e304267bf26042808bf0bb0ab1f8828d | Inventory management |
| 3 | Daily Worker Attendance | 27655cc2ac5c4affa8fb4bb3fe1d8714 | Attendance tracking |
| 4 | Raw Material Inward Entry | 0286e5cc5ea54788bdcd1189c1115adc | Material receipt |
| 5 | Product Outward Sales | 389012c3cd71402894d7273e17e59fac | Sales & dispatch |
| 6 | Production Entry & Tracking | 2d16a9c7dfb148a5bf7e0704fc03ca40 | Production recording |
| 7 | Periodic Production Summary | b24a6d61fa944c258d34af4079439f5b | Production reports |
| 8 | Login & Database Selection | 0f17b9263a314ca9bbb559383b947559 | Authentication |
| 9 | System Settings & Master Data | 6ec58d903c3045279aefcf457e798798 | Configuration |

### Design Assets

All screen designs and HTML code are available in the Stitch project:
- **Project URL**: Access via Google Stitch
- **Project ID**: 13407358775887533421
- **Export Format**: HTML/CSS (downloadable from Stitch)

---

**Document Version**: 1.0  
**Created**: January 31, 2026  
**Author**: Design Analysis from Stitch Project
