import java.util.Scanner;
import java.util.InputMismatchException;

class MonException extends Exception {
    public MonException(String message) {
        super(message);
    }
}

public class tempCodeRunnerFile{
    public static void verifier(int temp) throws MonException {
        if (temp<=120 && temp>=-50) {
            throw new MonException("True !");
        }
        System.out.println("False !");
    }
    
    public static void main(String[] args) {
        Scanner clavier = new Scanner(System.in);
        int temp=0;
        System.out.print("Entrez le temperature : ");
            temp = clavier.nextInt();
            try {
                verifier(temp); 
            } catch (MonException e) {
                System.out.println("Exception personnalisée capturée : " + e.getMessage());
            }
    }

    
}