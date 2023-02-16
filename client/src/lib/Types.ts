export type TrendsTerm = {
  name: string;
  data: TrendsData[];
}

export type TrendsData = {
  name: string = "";
  geo: string = "";
  score: number = 0;
  dailyChange: number = 0;
  weeklyChange: number = 0;
  monthlyChange: number = 0;
  lastUpdate: string = "";
}

export type TableColumn = {
  Header: string;
  accessor: string;
}