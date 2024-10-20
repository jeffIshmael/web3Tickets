import { CalendarCheckIcon, CalendarIcon, PlusIcon, TicketIcon } from "lucide-react";
import Link from "next/link";

const NavItem = ({
  href,
  icon: Icon,
  label,
}: {
  href: string;
  icon: React.ElementType;
  label: string;
}) => (
  <Link
    href={href}
    className="flex flex-col items-center gap-1 text-gray-500 hover:text-gray-900"
  >
    <Icon className="h-6 w-6" />
    <span className="text-xs font-medium">{label}</span>
  </Link>
);

export default function Layout({ children }: { children: React.ReactNode }) {

  return (

    <div className="flex h-screen flex-col">
      <main className="flex-1 overflow-auto">
        <div className="p-4">
          {/* <h1 className="mb-4 text-2xl font-bold">Welcome to the Events App</h1>
          <p className="mb-8 text-gray-500">
            Discover, create, and manage events all in one place.
          </p> */}

          {children}
        </div>
      </main>
      <nav className="sm:hidden flex items-center justify-between bg-white py-2 px-4">
        <NavItem href="/events" icon={CalendarIcon} label="Events" />
        <NavItem href="/create-event" icon={PlusIcon} label="Create Event" />
        <NavItem href="/my-events" icon={CalendarCheckIcon} label="My Events" />
        <NavItem href="/my-tickets" icon={TicketIcon} label="My Tickets" />
      </nav>
     </div>
  );
}
