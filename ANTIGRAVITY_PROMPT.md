# Production Management Dashboard - Antigravity Build Prompt

## Project Overview

Build a comprehensive Production Management Dashboard for Windows using Flutter. This is a factory operations management system with portable database functionality (similar to Tally ERP software). The application must manage production data, inventory, attendance, logistics, and generate detailed reports.

---

## Core Requirements

### Database & File Management
1. **Portable Database System**
   - Use SQLite for database (must work from external drives like USB/hard disk)
   - On app launch, show database selection screen (file picker to browse and select database folder)
   - Support multiple accounts with password protection per database
   - Auto-detect and load database file if user selects containing folder
   - Store recent databases list (last 5 accessed) for quick selection
   - Automatic backup functionality (configurable frequency)

2. **Universal Date Selection**
   - Prominent date picker in top navigation bar
   - Date selection applies to ALL tabs simultaneously
   - Show visual indicators (dots) on calendar for dates with existing data
   - Quick buttons: Today, Yesterday, Last Week
   - When date is selected, all tabs auto-refresh to show that date's data
   - Allow editing of historical data for selected date

---

## Application Structure

### Main Navigation (9 Tabs)
1. **Dashboard** - Factory operations overview
2. **Attendance** - Worker attendance tracking
3. **Inward** - Raw material receipt
4. **Production** - Batch production entry
5. **Outward** - Product sales tracking
6. **Logistics** - Vehicle trip management
7. **Stock Level** - Inventory monitoring
8. **Summary** - Periodic reports
9. **Settings** - Master data management

### Layout
- **Sidebar:** 240px width (collapsible to 60px icon-only), vertical navigation with icons
- **Top Bar:** 64px height with company logo/name, universal date picker (center), theme toggle & user menu (right)
- **Content Area:** Remaining space with 32px padding

---

## Feature Specifications by Tab

### 1. DASHBOARD TAB

**UI Components:**
- 4 KPI cards in grid (2x2 on desktop):
  - Workers Present (count)
  - Batches Produced (count)
  - Raw Material Stock (status indicator)
  - Product Stock (status indicator)
- Stock Alerts section: List of low/critical stock items with color coding (Red: critical, Orange: warning)
- Production Trend Chart: Line chart showing batches produced over last 7 days

**Data Logic:**
- Pull data for selected date
- Calculate stock status based on minimum alert levels
- Aggregate production data for last 7 days from selected date

---

### 2. ATTENDANCE TAB

**Entry Form (Top Section):**
- Worker dropdown (searchable, from Settings)
- Status radio buttons (Full Day / Half Day)
- Time In picker (HH:MM, default current time)
- "Mark Attendance" button

**Attendance Log (Bottom Section):**
- Data table: Worker Name | Status | Time In | Time Out | Actions
- Time Out: Empty time picker for each row, "Update" button to save
- If no data for selected date, show empty state with illustration
- Default time-out: If not manually entered, set to 6:00 PM when saving

**Database Operations:**
- INSERT on "Mark Attendance"
- UPDATE on "Update Time Out"
- Query attendance by selected date

---

### 3. INWARD TAB

**Entry Form:**
- Raw Material dropdown (from Settings)
- Package/Bag Size (number input with unit from material settings)
- Quantity (number of packages)
- Auto-calculated Total Display: Size × Quantity = Total (with unit)
- Notes (optional textarea)
- Submit button

**Inward Log:**
- Table: Material | Size | Quantity | Total | Notes | Actions (Edit/Delete)
- Show all entries for selected date
- Edit: Opens inline edit or modal

**Database Operations:**
- INSERT new inward entry
- UPDATE raw material stock (add quantity)
- Support EDIT and DELETE with stock adjustments

---

### 4. PRODUCTION TAB

**Progressive Disclosure Form:**
1. **Step 1:** Category dropdown (only field visible initially)
2. **Step 2:** Once category selected → Product dropdown appears (filtered by category)
3. **Step 3:** Once product selected → Show all remaining fields:
   - Number of batches (number input)
   - Raw materials section (dynamic fields based on product's recipe):
     - For each raw material: Name, Unit, Quantity input
   - Total bags produced (calculated or manual input)
   - Worker selection: Checkbox list of available workers

**Production Log:**
- Expandable table rows
- Columns: Category | Product | Batches | Total Produced | Workers | Actions
- Expand row to see raw material breakdown

**Database Operations:**
- INSERT production entry
- DECREASE raw material stock (quantities used)
- INCREASE product stock (quantity produced)
- Link workers to production batch
- Stock validation: Warn if raw material quantity exceeds available stock

---

### 5. OUTWARD TAB

**Entry Form:**
- Product dropdown
- Bag size selection
- Quantity input
- Current stock display (real-time from database)
- Warning if quantity exceeds available stock
- Notes (optional)
- Submit button

**Outward Log:**
- Table: Product | Bag Size | Quantity | Notes | Actions

**Database Operations:**
- INSERT outward entry
- DECREASE product stock
- Prevent sale if insufficient stock (show error)

---

### 6. LOGISTICS TAB

**Vehicle Selection:**
- Horizontal scrolling cards or grid
- Each card: Vehicle Model, Registration Number, Active Trips Count
- Click card to select vehicle

**Add Trip Form (after vehicle selection):**
- Destination (text input)
- Driver name (dropdown from Settings - drivers only)
- Start kilometers (number)
- End kilometers (number)
- Total kilometers (auto-calculated: End - Start, read-only)
- Fuel cost (currency input)
- Fuel efficiency (auto-calculated if possible: km/liter)
- Time out (datetime picker)
- Time in (datetime picker)
- "Add Trip" button

**Trip History:**
- Table for selected vehicle showing all trips for selected date
- Columns: Destination | Driver | Kilometers | Fuel Cost | Efficiency | Time Out | Time In | Actions

**Database Operations:**
- Separate trip records per vehicle
- INSERT new trip
- Calculate totals per vehicle

---

### 7. STOCK LEVEL TAB

**Two-Panel Layout:**

**Raw Material Stock (Left Panel):**
- Table: Material Name | Current Stock | Unit | Status
- Status color coding based on minimum threshold:
  - Green (sufficient): Stock > 2x minimum
  - Orange (low): Stock between 1x-2x minimum
  - Red (critical): Stock < minimum
- Sortable columns

**Product Stock (Right Panel):**
- Table: Product Name | Current Stock | Unit | Status
- Same status logic as raw materials

**Alert Summary (Top):**
- Cards showing count of critical and low stock items
- Filter buttons (Show All | Low Only | Critical Only)

**Stock Calculation Logic:**
- Real-time calculation based on:
  - Inward entries (add to raw material stock)
  - Production entries (subtract from raw material, add to product stock)
  - Outward entries (subtract from product stock)
- Use FIFO method for stock tracking
- Calculate cumulative stock up to selected date

---

### 8. SUMMARY TAB

**Period Selector:**
- Tab-style buttons: Daily | Weekly | Monthly | Yearly
- Date range picker (changes based on period type)
- Export buttons: Excel | CSV | PDF (exports all sections)

**Summary Sections (Tabs or Accordion):**

**Attendance Summary:**
- Table: Worker Name | Total Days | Full Days | Half Days | Absent Days
- Calculate for selected period

**Inward Summary:**
- Table: Raw Material | Total Received | Unit | Number of Receipts

**Production Summary:**
- Table: Product | Total Batches | Total Quantity | Category

**Outward Summary:**
- Table: Product | Total Sold | Unit | Number of Sales

**Database Operations:**
- Aggregate queries with date range filters
- GROUP BY operations for summaries

---

### 9. SETTINGS TAB

**Sidebar Navigation (within Settings):**
- Workers
- Raw Materials
- Categories
- Vehicles
- Preferences

#### **Workers Management:**
- Toggle: Labourers | Drivers
- Add Worker form (modal):
  - Name (text)
  - City (text)
  - Phone Number (text)
  - Type (auto-set: Labour or Driver)
- Table: Name | City | Phone | Actions (Edit/Delete)
- Search/filter functionality

#### **Raw Materials Management:**
- Add Material form:
  - Material Name (text)
  - Unit (radio buttons: kg, g, L, mL, pieces, etc.)
  - Minimum Stock Alert Level (number)
- Table: Material Name | Unit | Min Alert Level | Actions

#### **Categories Management:**
Two-panel interface:

**Left Panel:** Category list
- Add Category button
- List of all categories (click to expand)

**Right Panel:** Category Details (when category selected)

**Adding Raw Materials to Category:**
- Multi-select dropdown (all available raw materials)
- Selected materials shown as chips/tags
- Save button

**Adding Products to Category:**
- Product Name (text input)
- Raw Materials multi-select (only materials in this category)
- "Select All" checkbox
- For each selected material: Quantity ratio input
- Add Product button

**Database Schema:**
- Categories table
- Category_RawMaterials junction table
- Products table
- Product_RawMaterials junction table (with quantities)

#### **Vehicles Management:**
- Add Vehicle form:
  - Vehicle Model (text)
  - Registration Number (text)
- Table: Model | Registration | Total Trips | Actions

#### **Preferences:**
- Theme toggle (Light/Dark)
- Date format selection (DD/MM/YYYY, MM/DD/YYYY, etc.)
- Default unit preferences
- Automatic backup:
  - Frequency dropdown (Daily, Weekly, Monthly)
  - Backup location selector
- Manual Backup button
- Manual Restore button
- Font size adjustment slider (Small/Medium/Large)

---

## Database Schema

### Core Tables

```sql
-- Users/Accounts
CREATE TABLE accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  password_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Workers (both labourers and drivers)
CREATE TABLE workers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  city TEXT,
  phone TEXT,
  type TEXT CHECK(type IN ('labour', 'driver')),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Raw Materials
CREATE TABLE raw_materials (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  unit TEXT NOT NULL,
  min_alert_level REAL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Category-RawMaterial Junction
CREATE TABLE category_raw_materials (
  category_id INTEGER,
  raw_material_id INTEGER,
  FOREIGN KEY(category_id) REFERENCES categories(id),
  FOREIGN KEY(raw_material_id) REFERENCES raw_materials(id),
  PRIMARY KEY(category_id, raw_material_id)
);

-- Products
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category_id INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(category_id) REFERENCES categories(id)
);

-- Product-RawMaterial Junction (with quantities/ratios)
CREATE TABLE product_raw_materials (
  product_id INTEGER,
  raw_material_id INTEGER,
  quantity_ratio REAL NOT NULL,
  FOREIGN KEY(product_id) REFERENCES products(id),
  FOREIGN KEY(raw_material_id) REFERENCES raw_materials(id),
  PRIMARY KEY(product_id, raw_material_id)
);

-- Vehicles
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  model TEXT NOT NULL,
  registration_number TEXT NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Attendance
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  worker_id INTEGER NOT NULL,
  date DATE NOT NULL,
  status TEXT CHECK(status IN ('full_day', 'half_day')),
  time_in TIME,
  time_out TIME,
  FOREIGN KEY(worker_id) REFERENCES workers(id),
  UNIQUE(worker_id, date)
);

-- Inward (Raw Material Receipts)
CREATE TABLE inward (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  raw_material_id INTEGER NOT NULL,
  date DATE NOT NULL,
  package_size REAL NOT NULL,
  quantity INTEGER NOT NULL,
  total REAL NOT NULL,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(raw_material_id) REFERENCES raw_materials(id)
);

-- Production
CREATE TABLE production (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  date DATE NOT NULL,
  batches INTEGER NOT NULL,
  total_quantity REAL NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(product_id) REFERENCES products(id)
);

-- Production-RawMaterial Usage
CREATE TABLE production_raw_materials (
  production_id INTEGER,
  raw_material_id INTEGER,
  quantity_used REAL NOT NULL,
  FOREIGN KEY(production_id) REFERENCES production(id),
  FOREIGN KEY(raw_material_id) REFERENCES raw_materials(id),
  PRIMARY KEY(production_id, raw_material_id)
);

-- Production-Worker Junction
CREATE TABLE production_workers (
  production_id INTEGER,
  worker_id INTEGER,
  FOREIGN KEY(production_id) REFERENCES production(id),
  FOREIGN KEY(worker_id) REFERENCES workers(id),
  PRIMARY KEY(production_id, worker_id)
);

-- Outward (Product Sales)
CREATE TABLE outward (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  date DATE NOT NULL,
  bag_size REAL NOT NULL,
  quantity INTEGER NOT NULL,
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(product_id) REFERENCES products(id)
);

-- Logistics/Trips
CREATE TABLE trips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  driver_id INTEGER NOT NULL,
  date DATE NOT NULL,
  destination TEXT NOT NULL,
  start_km REAL NOT NULL,
  end_km REAL NOT NULL,
  total_km REAL NOT NULL,
  fuel_cost REAL,
  time_out DATETIME,
  time_in DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(vehicle_id) REFERENCES vehicles(id),
  FOREIGN KEY(driver_id) REFERENCES workers(id)
);

-- Preferences/Settings
CREATE TABLE preferences (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

---

## State Management

Use **Riverpod** for state management with the following providers:

### Global Providers
```dart
// Selected date provider (affects all tabs)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Current database path provider
final databasePathProvider = StateProvider<String?>((ref) => null);
```

### Data Providers (per tab)
```dart
// Attendance data for selected date
final attendanceProvider = FutureProvider.family<List<Attendance>, DateTime>((ref, date) async {
  final db = ref.watch(databaseProvider);
  return await db.getAttendanceByDate(date);
});

// Similar providers for:
// - inwardProvider
// - productionProvider
// - outwardProvider
// - stockLevelProvider
// - etc.
```

### Computed Providers
```dart
// Stock calculation provider
final rawMaterialStockProvider = FutureProvider<Map<int, double>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  // Calculate stock up to selected date using FIFO
  // Return map of material_id -> current_stock
});
```

---

## Business Logic & Data Flow

### Stock Calculation (FIFO Method)

**Raw Material Stock:**
```
For each raw material:
  1. Get all inward entries up to selected date (chronological order)
  2. Get all production entries up to selected date (chronological order)
  3. Calculate: Total Inward - Total Used in Production = Current Stock
```

**Product Stock:**
```
For each product:
  1. Get all production entries up to selected date
  2. Get all outward entries up to selected date
  3. Calculate: Total Produced - Total Sold = Current Stock
```

### Stock Validation
- Before production: Check if sufficient raw materials available
- Before outward: Check if sufficient product stock available
- Show warnings/errors if insufficient

### Auto-calculations
- Production Total = Batches × (sum of bag sizes)
- Trip Total KM = End KM - Start KM
- Inward Total = Package Size × Quantity
- Fuel Efficiency = Total KM / Liters (if fuel in liters)

---

## Export Functionality

### Excel Export (.xlsx)
Use `excel` package:
- Generate separate sheets for each section
- Include headers with styling
- Format numbers and dates appropriately
- Add filters to header rows

### CSV Export (.csv)
Use `csv` package:
- Simple comma-separated format
- One file per section or combined
- UTF-8 encoding

### PDF Export (.pdf)
Use `pdf` package:
- Professional layout with company header
- Tables with proper formatting
- Page numbers and date generated
- Summary sections with clear headings

### Export Scopes
- **Daily:** All data for selected date
- **Weekly:** Aggregated data for selected week
- **Monthly:** Aggregated data for selected month
- **Yearly:** Aggregated data for selected year

---

## UI/UX Requirements

### Color Scheme (Light Mode)
- Primary Blue: #1976D2
- Secondary Green: #388E3C
- Warning Orange: #F57C00
- Error Red: #D32F2F
- Background: #FAFAFA
- Surface: #FFFFFF
- Text Primary: #212121
- Text Secondary: #757575
- Border/Divider: #E0E0E0

### Color Scheme (Dark Mode)
- Primary Blue: #42A5F5
- Background: #121212
- Surface: #1E1E1E
- Text Primary: #FFFFFF
- Text Secondary: #B0B0B0
- Border/Divider: #424242

### Typography
- Font: Segoe UI (Windows) / Roboto (fallback)
- Heading 1: 24px Bold
- Heading 2: 18px Semibold
- Body Large: 16px Medium
- Body: 14px Regular
- Caption: 12px Regular

### Components
- **Buttons:** Height 40px, border radius 4px, primary/secondary/danger variants
- **Inputs:** Height 44px, border 1px, padding 12px 16px
- **Cards:** Border radius 8px, shadow elevation 1-3
- **Tables:** Alternating row colors, 48px min row height, hover effects
- **Modals:** 480-600px width, centered, overlay with backdrop

### Responsive Breakpoints
- Minimum: 1280x720 (sidebar collapses, cards stack)
- Standard: 1366x768 (full sidebar, 2-column cards)
- Optimal: 1920x1080 (full sidebar, 3-4 column cards, side-by-side panels)

---

## Validation & Error Handling

### Input Validation
- Required field checks
- Number range validation (no negatives for quantities)
- Date validation (no future dates where inappropriate)
- Phone number format validation
- Unique constraint checks (e.g., registration numbers)

### Error Messages
- Clear, user-friendly messages
- Suggest solutions where possible
- Color-coded (red for errors, orange for warnings)

### Confirmation Dialogs
- Before deleting any record
- Before overwriting existing data
- Before closing without saving

---

## Performance Optimization

### Database
- Create indexes on frequently queried columns (date, foreign keys)
- Use transactions for bulk operations
- Lazy load data (pagination for large tables)
- Cache frequently accessed data

### UI
- Virtualized lists for long tables (use ListView.builder)
- Debounce search inputs
- Optimize rebuild cycles (use const widgets where possible)
- Lazy load tabs (build content only when tab is active)

### File Operations
- Background processing for exports
- Progress indicators for long operations
- Compress backup files

---

## Security & Data Integrity

### Password Security
- Hash passwords using bcrypt or similar
- Never store plain text passwords
- Implement password strength requirements

### Data Integrity
- Foreign key constraints enabled
- Transaction rollback on errors
- Validate all inputs before database operations
- Regular backup reminders

### File System Security
- Store database in user-selected location
- Support read-only mode for viewing archives
- Backup encryption option (advanced feature)

---

## Testing Requirements

### Unit Tests
- Database operations (CRUD for all tables)
- Stock calculation logic
- Date range calculations
- Export data generation

### Integration Tests
- Complete user flows (login → data entry → export)
- Stock updates across modules
- Date selection affecting all tabs

### UI Tests
- Navigation between tabs
- Form submissions
- Error state displays
- Responsive layout changes

---

## Development Roadmap

### Phase 1: Foundation (Week 1-2)
- Project setup with Flutter & dependencies
- Database schema implementation
- Login screen with database selection
- Basic navigation structure with sidebar and top bar
- Theme system (light/dark mode)

### Phase 2: Core Features (Week 3-5)
- Dashboard tab (KPI cards, chart, alerts)
- Attendance tab (full CRUD)
- Inward tab (full CRUD)
- Production tab (progressive form, stock integration)
- Outward tab (full CRUD with stock validation)

### Phase 3: Advanced Features (Week 6-7)
- Logistics tab (vehicle/trip management)
- Stock Level tab (real-time calculations with FIFO)
- Settings tab (all management sections)
- Universal date picker with all tab integration

### Phase 4: Reports & Export (Week 8)
- Summary tab (all period types, all sections)
- Excel export implementation
- CSV export implementation
- PDF export implementation

### Phase 5: Polish & Testing (Week 9-10)
- Responsive design refinement
- Accessibility improvements
- Performance optimization
- Comprehensive testing
- Automatic backup implementation
- Bug fixes and edge cases

### Phase 6: Final Delivery (Week 11)
- Final testing
- Documentation
- Deployment package
- User guide

---

## Critical Implementation Notes

1. **Universal Date Handling:**
   - Always filter database queries by selected date
   - Update all tabs when date changes
   - Use a global date provider accessible throughout the app

2. **Stock Calculation:**
   - Implement as a service/use case
   - Calculate cumulatively up to selected date
   - Cache results for performance
   - Recalculate when any inward/production/outward changes

3. **Progressive Disclosure (Production Tab):**
   - Use StatefulWidget or state management
   - Show/hide fields based on previous selections
   - Clear dependent fields when parent selection changes

4. **Database Portability:**
   - Use relative paths, not absolute
   - Test with external drives (USB, network drives)
   - Handle drive disconnection gracefully

5. **Export Quality:**
   - Match UI table layouts in exports
   - Include summary statistics
   - Professional formatting with headers/footers
   - Date range clearly indicated

6. **Error Recovery:**
   - Auto-save drafts where possible
   - Transaction rollback on errors
   - Clear error messages with suggested actions

---

## Success Criteria

- ✅ Application runs on Windows without installation
- ✅ Database works from external drives
- ✅ All 9 tabs functional with full CRUD operations
- ✅ Stock levels calculate correctly with FIFO method
- ✅ Universal date selection works across all tabs
- ✅ Exports generate correctly in all 3 formats (Excel, CSV, PDF)
- ✅ Automatic backup creates valid database copies
- ✅ Responsive UI works from 1280x720 to 1920x1080+
- ✅ Light and dark themes fully implemented
- ✅ No data loss or corruption during normal operations
- ✅ Performance remains smooth with 10,000+ records

---

## Additional Considerations

### Undo Functionality
- Implement undo for recent changes (last 10 actions)
- Store undo stack in memory
- Clear on app close or new date selection

### Keyboard Shortcuts
- Ctrl+N: New entry in current tab
- Ctrl+S: Save current form
- Ctrl+F: Focus search
- Ctrl+E: Export current view
- Ctrl+D: Open date picker
- Ctrl+T: Toggle theme

### Empty States
- Design friendly empty states for all tables
- Include illustrations and call-to-action buttons
- Example: "No attendance marked for this date. Click 'Mark Attendance' to get started."

### Loading States
- Skeleton loaders for tables
- Spinners for long operations
- Progress bars for exports and backups

---

## Final Notes for Antigravity

This application requires careful attention to:
1. **Data consistency:** Stock calculations must be accurate and real-time
2. **User experience:** The UI should be intuitive despite complex functionality
3. **Performance:** Large datasets should not slow down the application
4. **Reliability:** No data loss under any circumstances
5. **Portability:** Must work seamlessly from external drives

Please build this application following Flutter best practices, implement comprehensive error handling, and ensure all features are production-ready. The target users are non-technical factory managers, so the UI must be extremely user-friendly.

Generate the complete Flutter application with all features specified above, organized according to the project structure outlined in Section 2.2, and ready for deployment as a Windows desktop application.
