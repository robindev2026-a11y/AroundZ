import { useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import { Onboarding } from "./screens/Onboarding";
import { Welcome } from "./screens/auth/Welcome";
import { PhoneEntry } from "./screens/auth/PhoneEntry";
import { OTPVerification } from "./screens/auth/OTPVerification";
import { CreateProfile } from "./screens/auth/CreateProfile";
import { Permissions } from "./screens/auth/Permissions";
import { AllSet } from "./screens/auth/AllSet";
import { Discovery } from "./screens/Discovery";
import { CreateActivity } from "./screens/CreateActivity";
import { MyActivities } from "./screens/MyActivities";
import { Messages } from "./screens/Messages";
import { Profile } from "./screens/Profile";
import { ActivityDetails } from "./screens/ActivityDetails";
import { BottomNav } from "./components/BottomNav";

import { Notifications } from "./screens/Notifications";
import { CreateSuccess } from "./screens/CreateSuccess";
import { TrustFlow } from "./screens/TrustFlow";

export type Screen =
  | "onboarding"
  | "welcome"
  | "phone"
  | "otp"
  | "create-profile"
  | "permissions"
  | "all-set"
  | "discovery"
  | "my-activities"
  | "messages"
  | "notifications"
  | "profile"
  | "create-activity"
  | "create-success"
  | "trust-flow"
  | "activity-details";

export type Activity = {
  id: string;
  type: string;
  icon: string;
  posterName: string;
  posterAvatar?: string;
  location: string;
  time: string;
  distance: string;
  duration: string;
  description: string;
  image: string;
  vibe: string;
  participantsCount: number;
  participants: { id: string; name: string; avatar: string }[];
  energyLevel: "Low" | "Medium" | "High";
  tags: string[];
  expectations: string[];
  organizerBio: string;
};

export type Message = {
  id: string;
  text: string;
  sender: "user" | "other";
  timestamp: string;
};

export default function App() {
  const [currentScreen, setCurrentScreen] =
    useState<Screen>("onboarding");
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [phoneNumber, setPhoneNumber] = useState("");
  const [userName, setUserName] = useState("Riley"); // Default for dev
  const [userAvatar, setUserAvatar] = useState("");
  const [selectedActivity, setSelectedActivity] =
    useState<Activity | null>(null);
  const [lastCreatedActivity, setLastCreatedActivity] =
    useState<any>(null);

  const navigateTo = (screen: Screen) => {
    setCurrentScreen(screen);
  };

  const completeAuth = () => {
    setIsAuthenticated(true);
    navigateTo("discovery");
  };

  const [activities, setActivities] = useState<Activity[]>([
    {
      id: "1",
      type: "Sunset Walk",
      icon: "🌅",
      posterName: "Alex",
      posterAvatar:
        "https://images.unsplash.com/photo-1775360338310-55e70d5e211c?auto=format&fit=crop&w=200&q=80",
      location: "The Commons",
      time: "6:30 PM",
      distance: "0.4 km",
      duration: "1-2 hours",
      description:
        "Taking a break from work. Anyone up for a walk and good conversation?",
      image:
        "https://images.unsplash.com/photo-1758613171826-94fe6df8fd44?auto=format&fit=crop&w=800&q=80",
      vibe: "Relaxed",
      participantsCount: 4,
      participants: [
        {
          id: "p1",
          name: "Sarah",
          avatar:
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80",
        },
        {
          id: "p2",
          name: "James",
          avatar:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80",
        },
        {
          id: "p3",
          name: "Maya",
          avatar:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80",
        },
      ],
      energyLevel: "Low",
      tags: ["Nature", "Convo", "Quiet"],
      expectations: [
        "Wear comfy shoes",
        "Bring water",
        "Casual pace",
      ],
      organizerBio:
        "Love exploring city parks and finding the best sunset spots.",
    },
    {
      id: "2",
      type: "Photo Session",
      icon: "📸",
      posterName: "Jordan",
      posterAvatar:
        "https://images.unsplash.com/photo-1763328719057-ff6b03c816d0?auto=format&fit=crop&w=200&q=80",
      location: "Riverside Trail",
      time: "4:45 PM",
      distance: "1.2 km",
      duration: "1 hour",
      description:
        "Street photography session around the historic district. 📸",
      image:
        "https://images.unsplash.com/photo-1552968431-f18ca2292af0?auto=format&fit=crop&w=800&q=80",
      vibe: "Creative",
      participantsCount: 2,
      participants: [
        {
          id: "p4",
          name: "Leo",
          avatar:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80",
        },
      ],
      energyLevel: "Medium",
      tags: ["Art", "Skills", "Outdoor"],
      expectations: [
        "Bring any camera",
        "Open to sharing tips",
        "Friendly vibes",
      ],
      organizerBio:
        "Freelance photographer looking for creative peers.",
    },
  ]);

  const handlePostActivity = (activityData: any) => {
    const newActivity: Activity = {
      id: activityData.id,
      type: activityData.type,
      icon: activityData.icon,
      posterName: activityData.posterName,
      posterAvatar:
        userAvatar ||
        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
      location: activityData.location,
      time: activityData.time,
      distance: activityData.distance || "0.1 km",
      duration: activityData.duration,
      description:
        activityData.description ||
        "Join me for a spontaneous meetup!",
      image:
        activityData.image ||
        "https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=800&q=80",
      vibe: activityData.vibe || "Chill",
      participantsCount: 1,
      participants: [],
      energyLevel: "Medium",
      tags: ["New"],
      expectations: ["Be yourself"],
      organizerBio: "Hey, I am new here!",
    };
    setActivities([newActivity, ...activities]);
    setLastCreatedActivity(newActivity);
    navigateTo("create-success");
  };

  // Render auth flow
  if (!isAuthenticated) {
    return (
      <div className="h-screen w-full max-w-md mx-auto bg-bg-primary overflow-hidden">
        <AnimatePresence mode="wait">
          {currentScreen === "onboarding" && (
            <Onboarding
              key="onboarding"
              onComplete={() => navigateTo("phone")}
            />
          )}
          {currentScreen === "phone" && (
            <PhoneEntry
              key="phone"
              onBack={() => navigateTo("welcome")}
              onContinue={(phone) => {
                setPhoneNumber(phone);
                navigateTo("otp");
              }}
            />
          )}
          {currentScreen === "otp" && (
            <OTPVerification
              key="otp"
              phoneNumber={phoneNumber}
              onVerify={() => navigateTo("create-profile")}
            />
          )}
          {currentScreen === "create-profile" && (
            <CreateProfile
              key="create-profile"
              onBack={() => navigateTo("otp")}
              onContinue={(name, avatar) => {
                setUserName(name);
                setUserAvatar(avatar);
                navigateTo("permissions");
              }}
            />
          )}
          {currentScreen === "permissions" && (
            <Permissions
              key="permissions"
              onContinue={() => navigateTo("all-set")}
            />
          )}
          {currentScreen === "all-set" && (
            <AllSet key="all-set" onContinue={completeAuth} />
          )}
        </AnimatePresence>
      </div>
    );
  }

  // Render main app screens
  return (
    <div className="h-screen w-full max-w-md mx-auto bg-bg-primary flex flex-col overflow-hidden relative">
      <div className="flex-1 overflow-hidden relative">
        <AnimatePresence>
          {currentScreen === "discovery" && (
            <motion.div
              key="discovery"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <Discovery
                userName={userName}
                activities={activities}
                onNavigateToCreate={() =>
                  navigateTo("create-activity")
                }
                onNavigateToNotifications={() =>
                  navigateTo("notifications")
                }
                onSelectActivity={(activity) => {
                  setSelectedActivity(activity);
                  navigateTo("activity-details");
                }}
              />
            </motion.div>
          )}
          {currentScreen === "activity-details" &&
            selectedActivity && (
              <motion.div
                key="activity-details"
                initial={{ opacity: 0, x: 50 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 50 }}
                className="h-full"
              >
                <ActivityDetails
                  activity={selectedActivity}
                  onBack={() => navigateTo("discovery")}
                  onJoin={() => {
                    // Logic to join
                    navigateTo("messages");
                  }}
                  onMessage={() => navigateTo("messages")}
                />
              </motion.div>
            )}
          {currentScreen === "create-activity" && (
            <motion.div
              key="create-activity"
              initial={{ y: "100%" }}
              animate={{ y: 0 }}
              exit={{ y: "100%" }}
              transition={{
                type: "spring",
                damping: 25,
                stiffness: 200,
              }}
              className="h-full"
            >
              <CreateActivity
                userName={userName}
                onClose={() => navigateTo("discovery")}
                onPost={handlePostActivity}
              />
            </motion.div>
          )}
          {currentScreen === "my-activities" && (
            <motion.div
              key="my-activities"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <MyActivities userName={userName} />
            </motion.div>
          )}
          {currentScreen === "messages" && (
            <motion.div
              key="messages"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <Messages />
            </motion.div>
          )}
          {currentScreen === "notifications" && (
            <motion.div
              key="notifications"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <Notifications onBack={() => navigateTo("discovery")} />
            </motion.div>
          )}
          {currentScreen === "create-success" &&
            lastCreatedActivity && (
              <motion.div
                key="create-success"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="h-full"
              >
                <CreateSuccess
                  activity={{
                    title: lastCreatedActivity.type,
                    icon: lastCreatedActivity.icon,
                    time: lastCreatedActivity.time,
                    location: lastCreatedActivity.location,
                    image: lastCreatedActivity.image,
                  }}
                  onView={() => {
                    setSelectedActivity(lastCreatedActivity);
                    navigateTo("activity-details");
                  }}
                  onDone={() => navigateTo("discovery")}
                />
              </motion.div>
            )}
          {currentScreen === "trust-flow" && (
            <motion.div
              key="trust-flow"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <TrustFlow
                onComplete={() => navigateTo("profile")}
                onBack={() => navigateTo("profile")}
              />
            </motion.div>
          )}
          {currentScreen === "profile" && (
            <motion.div
              key="profile"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="h-full"
            >
              <Profile
                userName={userName}
                userAvatar={userAvatar}
                onLogout={() => {
                  setIsAuthenticated(false);
                  navigateTo("welcome");
                }}
                onNavigate={navigateTo}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {currentScreen !== "create-activity" &&
        currentScreen !== "activity-details" && (
          <BottomNav
            currentScreen={currentScreen}
            onNavigate={navigateTo}
          />
        )}
    </div>
  );
}