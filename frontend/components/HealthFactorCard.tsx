type Props = {
  healthFactor: number | null;
};

export default function HealthFactorCard({ healthFactor }: Props) {
  return (
    <div>
      <h2>Health Factor</h2>
      <p>{healthFactor ? healthFactor.toFixed(2) : "Loading..."}</p>
    </div>
  );
}
