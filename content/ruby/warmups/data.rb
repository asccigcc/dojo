# Shared warm-up data, loaded before every warm-up rep.
FILLS = [
  { id: "rx1", patient: "ana", drug: "metformin",    day: 5, cents: 1200 },
  { id: "rx2", patient: "ben", drug: "lisinopril",   day: 2, cents: 800 },
  { id: "rx3", patient: "ana", drug: "atorvastatin", day: 9, cents: 1500 },
  { id: "rx4", patient: "cy",  drug: "metformin",    day: 2, cents: 1200 },
  { id: "rx5", patient: "ben", drug: "metformin",    day: 7, cents: 1200 }
].freeze
WORDS = %w[call sms call email call sms].freeze
NUMS = [5, 3, 8, 1, 9, 2].freeze
TIMES = [90, 100, 105, 110, 400].freeze
NURSES = %w[ana ben cy].freeze
PERIODS = [[15, 20], [1, 10], [11, 12], [18, 25]].freeze
SEQ = [3, 1, 4, 1, 5, 9, 2, 6, 5].freeze
PLAN = { "m1" => { coverage: { payer: "Aetna", tier: 2 } } }.freeze
LINES = ["100,m1,call", " 105 , m2 , sms ", "bad", "abc,m3,call", "90,m2,call", "120,m4,call,extra"].freeze
