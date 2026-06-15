import { useState, useRef, useEffect } from 'react';
import { 
  ArrowLeft, 
  Send, 
  Mic, 
  Smile, 
  Plus, 
  MapPin, 
  Clock, 
  MoreVertical, 
  Heart,
  CheckCheck,
  Zap,
  ChevronRight
} from 'lucide-react';
import { Avatar } from '../components/Avatar';
import { motion, AnimatePresence } from 'motion/react';
import { Button } from '../components/Button';

type MessageThread = {
  id: string;
  userName: string;
  userAvatar?: string;
  lastMessage: string;
  timestamp: string;
  unread: boolean;
  activity: string;
  icon: string;
  status?: string;
  countdown?: string;
};

type ChatMessage = {
  id: string;
  text: string;
  sender: 'user' | 'other';
  timestamp: string;
  reactions?: string[];
  status?: 'sent' | 'delivered' | 'read';
};

const mockThreads: MessageThread[] = [
  {
    id: '1',
    userName: 'Alex',
    userAvatar: 'https://images.unsplash.com/photo-1775360338310-55e70d5e211c?auto=format&fit=crop&w=200&q=80',
    lastMessage: 'I just reached the fountain! ⛲️',
    timestamp: '2m ago',
    unread: true,
    activity: 'Sunset Walk',
    icon: '🌅',
    status: 'Starting soon',
    countdown: '25m'
  },
  {
    id: '2',
    userName: 'Jordan',
    userAvatar: 'https://images.unsplash.com/photo-1763328719057-ff6b03c816d0?auto=format&fit=crop&w=200&q=80',
    lastMessage: 'That photo turned out great!',
    timestamp: 'Yesterday',
    unread: false,
    activity: 'Photo Session',
    icon: '📸'
  }
];

const mockMessages: ChatMessage[] = [
  {
    id: '1',
    text: "Hey everyone! I'm heading over to The Commons now. 🚶‍♂️",
    sender: 'other',
    timestamp: '3:45 PM',
    status: 'read'
  },
  {
    id: '2',
    text: "Awesome, I'm just finishing up some work and then I'll be there. Should take about 10 mins!",
    sender: 'user',
    timestamp: '3:46 PM',
    status: 'read'
  },
  {
    id: '3',
    text: "I just reached the fountain! ⛲️ It's a beautiful evening.",
    sender: 'other',
    timestamp: '4:02 PM',
    reactions: ['❤️', '✨'],
    status: 'read'
  }
];

export function Messages() {
  const [threads] = useState<MessageThread[]>(threadsList);
  const [selectedThread, setSelectedThread] = useState<MessageThread | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>(mockMessages);
  const [newMessage, setNewMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, selectedThread]);

  const handleSendMessage = () => {
    if (!newMessage.trim()) return;

    const message: ChatMessage = {
      id: Date.now().toString(),
      text: newMessage,
      sender: 'user',
      timestamp: new Date().toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit'
      }),
      status: 'sent'
    };

    setMessages([...messages, message]);
    setNewMessage('');
    
    // Fake response behavior
    setTimeout(() => {
      setIsTyping(true);
      setTimeout(() => {
        setIsTyping(false);
        const response: ChatMessage = {
          id: (Date.now() + 1).toString(),
          text: "Can't wait! See you there in a bit. 🙌",
          sender: 'other',
          timestamp: new Date().toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit'
          })
        };
        setMessages(prev => [...prev, response]);
      }, 2000);
    }, 1000);
  };

  const handleBack = () => {
    setSelectedThread(null);
  };

  // Inbox View
  if (!selectedThread) {
    return (
      <div className="h-full flex flex-col bg-[#F6F1EB] overflow-hidden">
        <header className="px-8 pt-16 pb-6 shrink-0">
          <div className="flex items-center justify-between mb-8">
            <h1 className="text-4xl font-black tracking-tight text-[#243447]">
              Messages
            </h1>
            <div className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] flex items-center justify-center text-[#243447]">
              <Zap className="w-6 h-6 fill-[#53B8A6] text-[#53B8A6]" />
            </div>
          </div>
          
          <div className="flex gap-4 overflow-x-auto no-scrollbar -mx-8 px-8 pb-2">
            {mockThreads.map(thread => (
              <motion.button
                key={`story-${thread.id}`}
                whileTap={{ scale: 0.95 }}
                className="flex flex-col items-center gap-2 shrink-0"
              >
                <div className="relative p-1 rounded-[22px] bg-gradient-to-tr from-[#53B8A6] to-[#8E7DBE]">
                  <div className="p-1 bg-[#F6F1EB] rounded-[18px]">
                    <Avatar src={thread.userAvatar} name={thread.userName} size="medium" className="ring-0" />
                  </div>
                </div>
                <span className="text-[10px] font-black text-[#243447] uppercase tracking-widest">{thread.userName}</span>
              </motion.button>
            ))}
          </div>
        </header>

        <div className="flex-1 overflow-y-auto px-6 pb-40 space-y-3">
          {mockThreads.map((thread, index) => (
            <motion.div
              key={thread.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              onClick={() => setSelectedThread(thread)}
              className="group cursor-pointer"
            >
              <div className="bg-white rounded-[32px] p-5 flex items-center gap-4 border border-[#E7DED4] transition-all duration-300 hover:shadow-lg hover:-translate-y-0.5 group-active:scale-[0.98]">
                <div className="relative">
                  <Avatar src={thread.userAvatar} name={thread.userName} size="large" className="ring-2 ring-[#53B8A6]/10" />
                  {thread.unread && (
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-[#53B8A6] border-4 border-white rounded-full" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h3 className="font-black text-[#243447] text-lg">
                      {thread.userName}
                    </h3>
                    <span className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">
                      {thread.timestamp}
                    </span>
                  </div>
                  <div className="flex items-center gap-2 mb-1.5">
                    <span className="text-xs">{thread.icon}</span>
                    <span className="text-[10px] font-black text-[#8E7DBE] uppercase tracking-widest">{thread.activity}</span>
                  </div>
                  <p className={`text-sm truncate ${thread.unread ? 'text-[#243447] font-bold' : 'text-[#5F6368] font-medium'}`}>
                    {thread.lastMessage}
                  </p>
                </div>
                <div className="opacity-0 group-hover:opacity-100 transition-opacity">
                  <ChevronRight className="w-5 h-5 text-[#E7DED4]" />
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    );
  }

  // Chat Thread View
  return (
    <div className="h-full flex flex-col bg-[#F6F1EB] overflow-hidden relative">
      {/* Floating Header */}
      <header className="fixed top-0 left-0 right-0 z-40 px-6 pt-14 pb-6 bg-[#F6F1EB]/80 backdrop-blur-xl border-b border-[#E7DED4]">
        <div className="flex items-center gap-4">
          <motion.button 
            whileTap={{ scale: 0.9 }}
            onClick={handleBack} 
            className="w-12 h-12 flex items-center justify-center rounded-2xl bg-white border border-[#E7DED4] text-[#243447]"
          >
            <ArrowLeft className="w-6 h-6" />
          </motion.button>
          
          <div className="flex-1 flex items-center gap-3">
            <div className="relative">
              <Avatar src={selectedThread.userAvatar} name={selectedThread.userName} size="medium" className="ring-2 ring-[#53B8A6]/20" />
              <div className="absolute bottom-0 right-0 w-3.5 h-3.5 bg-[#53B8A6] border-2 border-[#F6F1EB] rounded-full" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-lg font-black text-[#243447]">
                  {selectedThread.userName}
                </h2>
                <div className="px-2 py-0.5 rounded-full bg-[#53B8A6]/10 text-[#53B8A6] text-[10px] font-black uppercase tracking-wider">
                  Host
                </div>
              </div>
              <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.2em]">
                {selectedThread.status || 'Active Now'}
              </p>
            </div>
          </div>

          <button className="w-12 h-12 flex items-center justify-center rounded-2xl bg-white border border-[#E7DED4] text-[#243447]">
            <MoreVertical className="w-6 h-6" />
          </button>
        </div>

        {/* Meetup Context Banner */}
        <motion.div 
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-4 bg-white rounded-2xl p-3 border border-[#E7DED4] flex flex-col gap-2 shadow-sm"
        >
          <div className="flex items-center justify-between w-full">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#F6F1EB] flex items-center justify-center text-xl">
                {selectedThread.icon}
              </div>
              <div>
                <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-widest">Ongoing Meetup</p>
                <p className="text-sm font-bold text-[#243447]">{selectedThread.activity}</p>
              </div>
            </div>
            {selectedThread.countdown && (
              <div className="flex items-center gap-2 bg-[#8E7DBE]/10 px-3 py-1.5 rounded-xl border border-[#8E7DBE]/20">
                <Clock className="w-3.5 h-3.5 text-[#8E7DBE]" />
                <span className="text-[10px] font-black text-[#8E7DBE] uppercase tracking-wider">{selectedThread.countdown} left</span>
              </div>
            )}
          </div>
          
          <div className="h-px bg-[#F6F1EB] w-full" />
          
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="flex -space-x-2">
                <div className="w-5 h-5 rounded-full bg-[#53B8A6] border border-white flex items-center justify-center">
                  <div className="w-1 h-1 rounded-full bg-white animate-pulse" />
                </div>
                <Avatar size="small" className="w-5 h-5 border border-white" name="Sarah" />
              </div>
              <span className="text-[9px] font-bold text-[#5F6368] uppercase tracking-wider">People are arriving at the location</span>
            </div>
            <button className="text-[9px] font-black text-[#53B8A6] uppercase tracking-widest">View Map</button>
          </div>
        </motion.div>
      </header>

      {/* Messages Scroll Area */}
      <div 
        ref={scrollRef}
        className="flex-1 overflow-y-auto px-6 pt-52 pb-32 space-y-8 no-scrollbar"
      >
        <div className="flex flex-col items-center gap-4 py-4">
          <p className="text-[10px] font-black text-[#5F6368] uppercase tracking-[0.3em] bg-white px-4 py-1.5 rounded-full border border-[#E7DED4] shadow-sm">
            Today • 3:45 PM
          </p>
          <div className="flex -space-x-3 mt-2">
            <Avatar size="small" className="border-2 border-white" name="Sarah" />
            <Avatar size="small" className="border-2 border-white" name="James" />
            <div className="w-8 h-8 rounded-full bg-[#53B8A6] border-2 border-white flex items-center justify-center text-[8px] font-black text-white">
              +5
            </div>
          </div>
          <p className="text-[10px] font-bold text-[#5F6368] opacity-60">Sarah and 6 others are in the chat</p>
        </div>

        <AnimatePresence>
          {messages.map((message, i) => {
            const isUser = message.sender === 'user';
            const showAvatar = !isUser && (i === 0 || messages[i-1].sender === 'user');
            
            return (
              <motion.div
                key={message.id}
                initial={{ opacity: 0, scale: 0.9, y: 10, x: isUser ? 20 : -20 }}
                animate={{ opacity: 1, scale: 1, y: 0, x: 0 }}
                className={`flex gap-3 ${isUser ? 'flex-row-reverse' : 'flex-row'}`}
              >
                {!isUser && (
                  <div className="w-10 shrink-0">
                    {showAvatar ? (
                      <Avatar src={selectedThread.userAvatar} name={selectedThread.userName} size="small" />
                    ) : null}
                  </div>
                )}
                
                <div className={`flex flex-col max-w-[75%] ${isUser ? 'items-end' : 'items-start'}`}>
                  <div className="relative group">
                    <div
                      className={`px-5 py-4 rounded-[30px] shadow-sm ${
                        isUser
                          ? 'bg-[#53B8A6] text-white rounded-tr-none'
                          : 'bg-white text-[#243447] border border-[#E7DED4] rounded-tl-none'
                      }`}
                    >
                      <p className="text-sm font-medium leading-relaxed">{message.text}</p>
                      
                      {/* Reactions */}
                      {message.reactions && (
                        <div className="absolute -bottom-3 right-2 flex gap-1">
                          {message.reactions.map((emoji, idx) => (
                            <div key={idx} className="bg-white border border-[#E7DED4] rounded-full px-1.5 py-0.5 text-xs shadow-sm">
                              {emoji}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                  
                  <div className={`mt-2 flex items-center gap-1.5 px-1 ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
                    <span className="text-[9px] font-black text-[#5F6368] opacity-40 uppercase tracking-widest">
                      {message.timestamp}
                    </span>
                    {isUser && message.status && (
                      <CheckCheck className={`w-3 h-3 ${message.status === 'read' ? 'text-[#53B8A6]' : 'text-[#5F6368]/30'}`} />
                    )}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>

        {isTyping && (
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex items-center gap-3"
          >
            <div className="w-10 shrink-0">
              <Avatar src={selectedThread.userAvatar} name={selectedThread.userName} size="small" />
            </div>
            <div className="bg-white border border-[#E7DED4] rounded-full px-4 py-2 shadow-sm flex gap-1">
              <span className="w-1.5 h-1.5 bg-[#53B8A6] rounded-full animate-bounce" />
              <span className="w-1.5 h-1.5 bg-[#53B8A6] rounded-full animate-bounce [animation-delay:0.2s]" />
              <span className="w-1.5 h-1.5 bg-[#53B8A6] rounded-full animate-bounce [animation-delay:0.4s]" />
            </div>
          </motion.div>
        )}
      </div>

      {/* Floating Input Area */}
      <div className="fixed bottom-10 left-6 right-6 z-50">
        <div className="relative">
          {/* Action Bar (Slide out from plus) */}
          <div className="absolute -top-16 left-0 flex gap-2">
            <motion.button 
              whileTap={{ scale: 0.9 }}
              className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-lg flex items-center justify-center text-[#243447]"
            >
              <MapPin className="w-5 h-5 text-[#53B8A6]" />
            </motion.button>
            <motion.button 
              whileTap={{ scale: 0.9 }}
              className="w-12 h-12 rounded-2xl bg-white border border-[#E7DED4] shadow-lg flex items-center justify-center text-[#243447]"
            >
              <Plus className="w-5 h-5 text-[#8E7DBE]" />
            </motion.button>
          </div>

          <div className="bg-white/90 backdrop-blur-2xl border border-[#E7DED4] rounded-[32px] p-2 flex items-center gap-2 shadow-2xl">
            <button className="w-12 h-12 rounded-2xl hover:bg-[#F6F1EB] flex items-center justify-center text-[#5F6368] transition-colors">
              <Smile className="w-6 h-6" />
            </button>
            
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
              placeholder="Type your message..."
              className="flex-1 h-12 px-2 text-sm font-bold text-[#243447] placeholder:text-[#5F6368]/40 focus:outline-none"
            />
            
            {newMessage.trim() ? (
              <motion.button
                initial={{ scale: 0, rotate: -45 }}
                animate={{ scale: 1, rotate: 0 }}
                onClick={handleSendMessage}
                className="w-12 h-12 bg-[#53B8A6] rounded-2xl flex items-center justify-center text-white shadow-[0_8px_16px_rgba(83,184,166,0.3)] active:scale-90 transition-all"
              >
                <Send className="w-5 h-5" />
              </motion.button>
            ) : (
              <motion.button
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="w-12 h-12 bg-[#F6F1EB] rounded-2xl flex items-center justify-center text-[#5F6368] active:scale-90 transition-all"
              >
                <Mic className="w-6 h-6" />
              </motion.button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

const threadsList = mockThreads;
