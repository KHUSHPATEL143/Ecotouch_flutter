# Production Management Dashboard

A comprehensive production management dashboard for Windows built with Flutter.

## Features

- **Dashboard**: Factory operations overview with KPIs and production trends
- **Attendance**: Worker attendance tracking with time in/out
- **Inward**: Raw material receipt management
- **Production**: Batch production entry with FIFO stock tracking
- **Outward**: Product sales and shipment tracking
- **Stock Level**: Real-time inventory monitoring with alerts
- **Summary**: Periodic reports (daily/weekly/monthly/yearly)
- **Settings**: Master data management (workers, materials, categories, vehicles)

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Database**: SQLite (portable, works from USB/external drives)
- **Export**: Excel, CSV, PDF
- **Charts**: FL Chart
- **Platform**: Windows Desktop

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Windows 10 or higher

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d windows
   ```

### Building for Release

```bash
flutter build windows --release
```

The executable will be located in `build\windows\runner\Release\`

## Database

The application uses a portable SQLite database that can be stored on:
- Local hard drive
- External USB drive
- Network drive

On first launch, you'll be prompted to select a database location.

## License

Proprietary - All rights reserved

## Support

For support, please contact the development team.
