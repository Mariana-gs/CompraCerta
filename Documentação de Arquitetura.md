# Documentação de Arquitetura – CompraCerta

## (i) Escolhas de Tecnologias

Para o desenvolvimento do CompraCerta, optou-se por utilizar Flutter como framework principal. A escolha se deu por sua capacidade de criar aplicativos multiplataforma com uma única base de código, permitindo que o app funcione tanto em Android quanto em iOS sem a necessidade de manter projetos separados. O Flutter oferece uma interface rica e responsiva, além de uma vasta coleção de widgets prontos seguindo o padrão Material Design, garantindo uma experiência de usuário moderna e consistente.

A linguagem escolhida foi Dart, que é a linguagem nativa do Flutter. Dart é moderna, tipada e possui suporte robusto à programação orientada a objetos e reativa, permitindo escrever código limpo, legível e de fácil manutenção.

Para o gerenciamento de estado, optou-se pelo uso do Provider ou Riverpod, soluções eficientes e amplamente adotadas na comunidade Flutter. Essa escolha permite que a interface seja reativa, atualizando em tempo real os totais de compras, comparações de preço por unidade e alertas de orçamento, sem a necessidade de reconstruções complexas da UI.

Como o aplicativo terá persistência local, os dados das listas de compras e do orçamento serão mantidos no dispositivo, utilizando Hive ou SQLite. Essa decisão garante que os dados persistam entre sessões, mantendo a aplicação leve e rápida.

Por fim, para a interface e design visual, utilizou-se o padrão Material Design 3, fornecido pelo Flutter, garantindo que a UI seja intuitiva, acessível e consistente, seguindo boas práticas de design para aplicativos móveis.

---

## (ii) Projeto Arquitetural Elaborado

O aplicativo será construído usando uma arquitetura em camadas, adaptada para Flutter:

### 1. Camadas

UI Layer (Apresentação)  
- Telas e widgets Flutter exibindo listas, itens, orçamentos e totais.  
- A UI consome dados do State Manager e se atualiza automaticamente.  

Application Layer (Lógica / Estado)  
- Controllers e services que lidam com regras de negócio:  
  - Adição, remoção e edição de itens.  
  - Cálculo de totais e comparação de preços.  
- State Manager (Provider/Riverpod) mantém o estado reativo e sincroniza com o armazenamento local.  

Domain Layer (Modelos)  
- Entidades principais: Item, ListaDeCompras, Orcamento.  
- Representa o modelo de negócio do app.  

Persistence Layer (Persistência Local)  
- Inclui armazenamento local usando opções como:  
  - Hive: banco de dados NoSQL rápido e leve para Flutter.  
  - SQLite (via sqflite): banco relacional local para armazenar listas e itens.  
- Essa camada garante que os dados da lista de compras sejam salvos no dispositivo e persistam entre sessões.

### 2. Diagramas do Modelo C4

Diagrama de Contexto (Nível 1)  

![Nível 1](modeloC4Img\nivel1.png)


Diagrama de Contêineres (Nível 2)  

![Nível 2](modeloC4Img\nivel2.png)

Diagrama de Componentes (Nível 3)  

![Nível 3](modeloC4Img\nivel3.png)

Diagrama de Código / Estrutura (Nível 4)  

![Nível 4](modeloC4Img\nivel4.png)

---

## (iii) Justificativa do Modelo Escolhido

O aplicativo CompraCerta foi desenvolvido com uma arquitetura em camadas, combinada com o C4 Model para documentação e visualização clara do sistema. Essa abordagem foi escolhida por oferecer modularidade, clareza e facilidade de manutenção, essenciais em um aplicativo móvel que gerencia listas de compras, comparações de preços e controle de orçamento.

A separação de responsabilidades é um dos pontos centrais dessa arquitetura. A camada de interface (UI Layer) é responsável apenas por exibir informações e interagir com o usuário, tendo a HomeScreen como tela principal de comparação de preços por unidade, além de mostrar alertas de orçamento. A camada de aplicação (Application Layer) contém os controllers e serviços que realizam os cálculos de totais e comparações, além de gerenciar o estado do app de forma reativa com Provider/Riverpod, garantindo que a interface seja atualizada automaticamente sempre que os dados mudam. A camada de domínio (Domain Layer) concentra os modelos de negócio, mantendo a lógica do sistema separada da interface. Por fim, a camada de persistência (Persistence Layer) garante que as listas e itens selecionados sejam salvos localmente no dispositivo, utilizando Hive ou SQLite, permitindo que os dados persistam entre sessões sem comprometer a performance do app.

O uso do C4 Model para documentação complementa a arquitetura, permitindo visualizar o sistema em quatro níveis: contexto, contêineres, componentes e código. Isso facilita a comunicação da estrutura para novos desenvolvedores e serve como referência clara para manutenção ou evolução do sistema. Além disso, a arquitetura adotada é escalável, permitindo futuras integrações com backend, filtros avançados de itens ou sincronização em nuvem, sem exigir mudanças profundas na estrutura existente.

Em resumo, a combinação da arquitetura em camadas com o C4 Model proporciona um sistema claro, modular e eficiente, que separa interface, lógica de negócio, modelos de domínio e persistência, garantindo que o CompraCerta seja fácil de manter, evoluir e compreender, enquanto oferece uma experiência de usuário rápida e confiável.
