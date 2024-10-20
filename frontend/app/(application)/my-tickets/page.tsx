"use client";

import Image from "next/image";
import { useReadContract, useAccount } from "wagmi";
import {
  blocTicketsAbi,
  contractAddress,
} from "@/blockchain/abi/blocTickets-abi";
import { Skeleton } from "@/components/ui/skeleton";
import { Header } from "@/components/header";
import { useEffect } from "react";

const Page = () => {
  const { isConnected, address } = useAccount();
  const { data, isPending, error } = useReadContract({
    address: contractAddress,
    abi: blocTicketsAbi,
    functionName: "getUserTickets",
    args: [address!!],
  });

  useEffect(() => {
    console.log(data);
  }, [data]);

  const tickets = data || [];

  return (
    <main className="flex flex-col min-h-screen bg-gray-100">
      {/* Header */}
      <div className="hidden sm:block">
        <Header />
      </div>

      {/* Page Content */}
      <div className="flex-1 px-4 py-8 md:px-6 lg:px-10">
        <h1 className="mb-6 text-3xl font-bold text-gray-800">My Tickets</h1>

        {/* If wallet is not connected */}
        {!isConnected && (
          <div className="flex h-screen items-center justify-center">
            <p className="text-lg text-gray-600">Please connect your wallet</p>
          </div>
        )}

        {/* Error State */}
        {error && isConnected && (
          <div className="flex h-screen items-center justify-center">
            <p className="text-lg text-400">
              Error fetching tickets. Please connect your wallet and try again.
            </p>
          </div>
        )}

        {/* No Tickets State */}
        {tickets?.length === 0 && isConnected && (
          <div className="flex h-screen items-center justify-center">
            <div className="text-center">
              <p className="text-lg text-gray-600">
                You have not purchased any tickets yet.
              </p>
             
              <div className="mt-4">
                <Image
                  src="/static/images/ticket/No-Tickets.jpg" // Replace with an appropriate image path
                  alt="No tickets"
                  className="rounded-full"
                  width={200}
                  height={200}
                />
              </div>
            </div>
          </div>
        )}

        {/* Loading State */}
        {isPending ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {/* Skeleton Loader */}
            {[...Array(4)].map((_, idx) => (
              <Skeleton key={idx} className="h-[300px] w-[450px] rounded-xl" />
            ))}
          </div>
        ) : (
          /* Tickets Grid */
          <div className="grid gap-6 sm:grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
            {tickets?.map((ticket: string, idx: number) => (
              <div
                key={idx}
                className="bg-white shadow-lg rounded-lg overflow-hidden transform transition duration-300 hover:scale-105 hover:shadow-lg"
              >
                <Image
                  height="300"
                  src={`https://ipfs.io/ipfs/${ticket}`}
                  width="550"
                  alt="ticket"
                  className="object-cover"
                />
               
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  );
};

export default Page;
