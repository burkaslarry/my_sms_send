# SMS Campaign Manager - Complete Application

A full-stack SMS campaign management system with:
- 🚀 **Python FastAPI** backend (DeepSeek AI integration)
- ⚡ **Next.js** frontend (React + Tailwind)
- 🗄️ **Supabase** database
- ⏰ **Automated cron jobs** for scheduled sending

## 📋 Project Structure

```
my_sms_send/
├── backend/                    # Python FastAPI server
├── frontend/                   # Next.js application
├── supabase/                   # Database schema
├── .github/workflows/          # GitHub Actions workflows
├── .gitignore
└── README.md
```

## 🔧 Quick Start

### 1. Set Up Supabase
1. Create a Supabase project
2. Execute SQL from `supabase/schema.sql`
3. Get your credentials

### 2. Set Up Backend (Python)
```bash
cd backend
cp .env.example .env
pip install -r requirements.txt
python main.py
```

### 3. Set Up Frontend (Next.js)
```bash
cd frontend
cp .env.example .env.local
npm install
npm run dev
```

## 📚 Documentation

- **Backend API**: http://localhost:8000/docs
- **Backend README**: [backend/README.md](backend/README.md)
- **Frontend README**: [frontend/README.md](frontend/README.md)

## 📄 License

Open source and available for personal and commercial use.

## Key Features:

Interactive spinning wheel: Engage users with a visually appealing and interactive luck wheel.
Customizable segments: Create wheel segments with diverse colors, labels, and rewards to align with your specific use cases.
Randomized outcomes: Generate random results upon spinning the wheel, adding an element of surprise and excitement.
Getting Started:

Clone the repository:
```
git clone https://github.com/your-username/flutter_luck_wheel.git
```

Install dependencies:

```
cd flutter_luck_wheel
flutter pub get
```

Run the app:

```
flutter run
```

## Resources:

Flutter documentation: https://docs.flutter.dev/
Lab: Write your first Flutter app: https://docs.flutter.dev/get-started/codelab
Cookbook: Useful Flutter samples: https://docs.flutter.dev/cookbook
Customization and Development:

Explore the project's code and structure to understand its components and functionality.
Modify the wheel's appearance and behavior by adjusting colors, labels, images, and animations within the code.
Implement additional features or logic as needed to tailor the wheel to your specific requirements.
Contributions:

Contributions and suggestions are welcome! Please create an issue or pull request on GitHub.
License:

This project is licensed under the MIT License.

## Additional Notes:

Feel free to contact the developer for further assistance or inquiries.
Share your experience and creations using this project!