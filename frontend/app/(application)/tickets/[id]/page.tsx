"use client";

import { useRouter } from "next/navigation";
import Image from "next/image";
import { useAccount, useReadContract } from "wagmi";
import { blocTicketsAbi, contractAddress } from "@/blockchain/abi/blocTickets-abi";
import { Skeleton } from "@/components/ui/skeleton";
import { Header } from "@/components/header";
import { Badge } from "@/components/ui/badge";
import { useEffect, useState } from "react";

export default function TicketsPage({ params }: { params: { id: number } }) {
  const { address, isConnected } = useAccount();
  const router = useRouter();
  const [isClient, setIsClient] = useState(false);

  // To prevent hydration issues, ensure the component only runs on the client
  useEffect(() => {
    setIsClient(true);
  }, []);

  const {
    data: nftTicketUri,
    isPending,
    error,
  } = useReadContract({
    address: contractAddress,
    abi: blocTicketsAbi,
    functionName: "getUserPurchasedTickets",
    args: [BigInt(params.id), address!!],
  });

  useEffect(() => {
    if (nftTicketUri) {
      console.log(nftTicketUri);
    }
  }, [nftTicketUri]);

  // Prevent rendering the content until the component is on the client-side
  if (!isClient) return null;

  return (
    <main className="px-4">
      <div className="hidden sm:block">
        <Header />
      </div>
      <div className="flex h-screen flex-col items-center justify-center rounded-lg bg-gray-100">
        {!isConnected && <p>Please connect your wallet to view your tickets</p>}
        {isPending && <Skeleton className="h-64 w-full rounded-lg" />}
        {nftTicketUri ? (
          <div className="flex h-screen w-full flex-col items-center justify-center gap-8 text-center">
            <Badge>Reload the page if you can&apos;t see your NFT Ticket</Badge>
            <p className="font-semibold text-green-600">Here is your NFT Ticket</p>
            <div className="px-6">
              <Image
                alt="NFT Ticket"
                className=""
                height="300"
                src={`https://ipfs.io/ipfs/${nftTicketUri[0]}`}
                width="450"
              />
            </div>
          </div>
        ) : (
          <p></p>
        )}
      </div>
    </main>
  );
}
