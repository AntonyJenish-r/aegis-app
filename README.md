🛡️ AEGIS – AI-Powered Personal Safety \& Emergency Response System



«“When you can't call for help, AEGIS calls for you.”»



AEGIS is an AI-powered personal safety and emergency response system designed to help users trigger emergency alerts when they may be unable to operate their phone normally.



The system combines manual SOS, voice, motion, location, and audio signals to detect potential emergencies and notify trusted contacts and emergency responders.



🚨 Problem



During situations such as harassment, assault, kidnapping, or other emergencies, a victim may not be able to unlock their phone or manually call for help.



Traditional safety applications often depend on manual activation, internet connectivity, or a single trigger mechanism.



AEGIS aims to reduce this dependency through a multi-modal emergency triggering system.



💡 Solution



AEGIS provides multiple ways to trigger an emergency:



\- 📱 Press-and-hold SOS

\- 🎤 Voice-based trigger

\- 📳 Motion/shake detection

\- 🤖 AI-based signal fusion

\- 📍 Live location sharing

\- 🎙️ 5-second distress audio

\- 📡 SMS fallback when internet is unavailable

\- 🔔 Emergency notifications to trusted contacts

\- 🚔 Dispatcher integration



⚙️ How It Works



1\. User activates SOS or an emergency signal is detected.

2\. A 5-second countdown allows the user to cancel a false alarm.

3\. The emergency event is processed by the AI engine.

4\. The incident is stored locally for offline support.

5\. Location information is sent to the backend.

6\. Trusted contacts receive an emergency notification.

7\. A dispatcher can receive the emergency event through WebSocket.

8\. Live GPS information can be shared during the incident.

9\. The user can resolve the emergency after reaching safety.



Emergency Flow



User

&#x20; ↓

SOS / Voice / Motion

&#x20; ↓

AI Fusion Engine

&#x20; ↓

Emergency Detection

&#x20; ↓

Location + Distress Audio

&#x20; ↓

&#x20;┌───────────────┬────────────────┐

&#x20;↓                    ↓                     ↓

Family           Dispatcher                SMS

&#x20;↓                    ↓                     ↓

Alert              Patrol                 Offline



✨ Key Features



Multi-Modal Smart Trigger



Combines press-hold, voice, and motion-based triggers.



🤖 AI Fusion Engine



Combines multiple signals to determine the possibility of a threat.



🎙️ Distress Audio



Captures a short distress-audio clip during an emergency trigger.



📍 Live GPS



Shares the user's live location during an active emergency.



📡 Offline-First



Uses local database storage and SMS fallback when internet connectivity is unavailable.



🚨 Manual SOS Override



A manually triggered SOS is treated as a critical emergency.



🔔 Dual-Channel Alerts



Emergency notifications can be sent to family/trusted contacts and a dispatcher simultaneously.



🛠️ Tech Stack



Mobile



\- Android

\- Jetpack Compose

\- Overlay API

\- Foreground Service



AI / ML



\- TensorFlow Lite

\- MediaPipe

\- Audio DSP

\- IMU \& Signal Fusion



Backend



\- Node.js / FastAPI

\- PostgreSQL

\- Firebase

\- Docker

\- SMS Gateway



Security



\- Android Keystore

\- On-device inference

\- No raw audio sent continuously



📱 Use Cases



\- Women travelling alone

\- Campus safety

\- Elderly people living alone

\- Solo travellers

\- Ride-share safety

\- Assault or kidnapping emergencies

\- Fall/shake detection



📊 Impact



AEGIS is designed to:



\- Improve emergency response time

\- Reduce dependency on manual phone operation

\- Provide live location during emergencies

\- Provide short distress-audio evidence

\- Support emergency alerts even with limited connectivity

\- Reduce false alarms through multi-signal confirmation



🔮 Future Scope



Phase 2



\- Wearable integration

\- Voice-activated SOS

\- Multi-language support

\- iOS + Android parity



Phase 3



\- Predictive AI

\- Community responders

\- Auto-call integration

\- Health-related emergency detection



Long-Term



\- Smart-city integration

\- Drone response

\- Satellite SOS

\- Global expansion



Author

R. Antony Jenish



GitHub: @AntonyJenish-r



Institution: Ponjesly College of Engineering

Year: 2026



🏆 Hackathon Project



AEGIS was developed as a hackathon project focusing on AI-powered personal safety, emergency detection, and rapid response.



⚠️ Disclaimer



AEGIS is a prototype/hackathon project. Emergency response features such as police dispatch, SMS delivery, GPS tracking, and AI-based detection may require additional testing, integrations, permissions, and validation before real-world deployment.

